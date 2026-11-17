#!/usr/bin/env bash
#
# Recreate an openshell dev sandbox from the config in this directory.
#   ./build-sandbox.sh [name] [extra sandbox create flags...]
#   IMAGE=devbox:abc1234 ./build-sandbox.sh probe
#
# Portable by substitution: dev-policy.yaml and the mount list below spell the home
# directory as @HOME@ and this script fills in $HOME. Nothing machine-specific is
# committed. See the OpenShell section of the README for the assumptions.
set -euo pipefail
# Follow the symlink stow installed, so the generated policy lands in the repo no
# matter whether this is run from the checkout or from ~/.config/openshell.
cd "$(dirname "$(readlink -f "$0")")"

name="${1:-dev-sandbox}"      # keep in sync with SBX in .zshrc
if [[ $# -gt 0 ]]; then shift; fi
image="${IMAGE:-devbox:sandbox}"
policy_src=dev-policy.yaml
# Absolute: the rendered policy is handed to another CLI, which may resolve a
# relative path against a different cwd (or a gateway process may never see ours).
policy_rendered="$PWD/dev-policy.rendered.yaml"

# Landlock seals the filesystem at exec, so policy edits need a recreate; neither
# this script nor dev-policy.yaml is read by `policy set`/`policy update`.
if [[ ! -f $policy_src ]]; then
    echo "run me from the dotfiles openshell dir ($policy_src missing)" >&2
    exit 1
fi

# $HOME is spliced into JSON (the mounts) and YAML (the policy) as a bare string, so
# a quote, a backslash or a space in a home path would corrupt the document instead
# of failing. Rejecting anything outside this charset is also what lets the path
# extraction below treat '"' and ' ' as delimiters.
if [[ ! $HOME =~ ^/[A-Za-z0-9._/-]+$ ]]; then
    echo "unsupported HOME: '$HOME' (want a plain path: ASCII letters, digits, . _ -)" >&2
    exit 1
fi

# The sandbox user comes from the node base image (uid 1000). Writable bind mounts
# are written as that uid, so a different host uid means ownership mismatches in the
# project directories rather than a hard failure — warn instead of silently continuing.
if [[ "$(id -u)" != 1000 ]]; then
    echo "warning: host uid is $(id -u), not 1000 -> expect permission mismatches on the writable mounts" >&2
fi

# Mounts are visibility, the policy is the permission boundary: don't mirror the
# policy's read/write split here. Landlock can only revoke, so a read_only home
# mount would make the project directories unwritable in a way the policy cannot undo.
# Quoted heredoc: @HOME@ is the only thing substituted, no other shell expansion.
mounts_json=$(cat <<'JSON'
{ "docker": { "mounts": [
  { "type": "bind", "source": "@HOME@/dotfiles",                           "target": "@HOME@/dotfiles",                           "read_only": true },
  { "type": "bind", "source": "@HOME@/dev",                                "target": "@HOME@/dev",                                "read_only": false },
  { "type": "bind", "source": "@HOME@/sbx",                                "target": "@HOME@/sbx",                                "read_only": false },
  { "type": "bind", "source": "@HOME@/.gitconfig",                         "target": "@HOME@/.gitconfig",                         "read_only": true },
  { "type": "bind", "source": "@HOME@/.gitconfig.local",                   "target": "@HOME@/.gitconfig.local",                   "read_only": true },
  { "type": "bind", "source": "@HOME@/.config/opencode/opencode.json",     "target": "@HOME@/.config/opencode/opencode.json",     "read_only": true },
  { "type": "bind", "source": "@HOME@/.config/nixos",                      "target": "@HOME@/.config/nixos",                      "read_only": false },
  { "type": "bind", "source": "@HOME@/.pi/agent/models.json",              "target": "@HOME@/.pi/agent/models.json",              "read_only": true },
  { "type": "bind", "source": "@HOME@/.pi/agent/settings.json",            "target": "@HOME@/.pi/agent/settings.json",            "read_only": true },
  { "type": "bind", "source": "@HOME@/.pi/agent/mcp.json",                 "target": "@HOME@/.pi/agent/mcp.json",                 "read_only": true }
] } }
JSON
)

# ------------------------------------------------------------------- checks
# The mount list, the policy and the image's /sandbox symlinks describe one set of
# paths. Check them against each other rather than leaving it to a comment: every
# check runs against the committed, un-substituted sources, so $HOME cannot paper
# over a typo, and a broken set never reaches a running sandbox.

# The home-relative paths each source names, as two sorted sets. Each source gets its
# own shape so that prose cannot masquerade as an entry: a quoted JSON attribute for
# the mounts, an indented `- ` list item for the YAML (a commented-out path is not a
# path). Set comparison rather than substring matching, so a /home/x/dev entry is not
# satisfied by /home/x/devbox.
to_path_set() {
    while IFS= read -r p; do printf '%s\n' "${p##*@HOME@/}"; done | sort -u
}
mount_paths=$(grep -oE '"@HOME@/[^"]*"' <<<"$mounts_json" | tr -d '"' | to_path_set)
policy_paths=$(grep -oE '^[[:space:]]*-[[:space:]]+@HOME@/[^[:space:]]+' "$policy_src" | to_path_set)

# (1) Each mount source must exist. Docker turns a missing bind source into a
# root-owned empty directory at the target, which shows up in the sandbox as a project
# directory that is inexplicably empty and unwritable — so name the path up front.
while IFS= read -r rel; do
    if [[ ! -e "$HOME/$rel" ]]; then
        echo "missing mount source: $HOME/$rel" >&2
        echo "  create it, or drop the entry from the mount list here and from $policy_src" >&2
        exit 1
    fi
done <<<"$mount_paths"

# (2) Mounts and policy must name exactly the same paths. A policy path that is not
# mounted is invisible in the sandbox; a mount the policy does not name is a hole
# Landlock cannot seal, because Landlock can only revoke.
if ! paths_diff=$(diff <(printf '%s\n' "$mount_paths") <(printf '%s\n' "$policy_paths")); then
    echo "the mount list and $policy_src do not name the same paths ('<' mount only, '>' policy only):" >&2
    printf '%s\n' "$paths_diff" >&2
    exit 1
fi

# (3) The image symlinks host files into /sandbox; a symlink whose target is not
# bind-mounted dangles, and the only symptom is an agent that silently finds no
# config file — which is what happened to opencode.json, mounted only after the fact.
if [[ ! -f Dockerfile.dev ]]; then
    echo "Dockerfile.dev missing next to $0 (the build would fail later anyway)" >&2
    exit 1
fi
while IFS= read -r link; do
    rel=${link#'$HOST_HOME/'}
    if ! grep -Fq -- "\"@HOME@/$rel\"" <<<"$mounts_json"; then
        echo "Dockerfile.dev symlinks \$HOST_HOME/$rel into /sandbox but it is not bind-mounted -> dangling symlink in the sandbox" >&2
        exit 1
    fi
done < <(grep -o '"\$HOST_HOME/[^"]*"' Dockerfile.dev | tr -d '"')

# Render with bash substitution, not sed: a home path containing & /\ would corrupt a
# sed substitution, and sed -i on the tracked file would edit the tracked file.
policy=$(<"$policy_src")
policy=${policy//@HOME@/$HOME}
if [[ $policy == *'@HOME@'* ]]; then
    echo "unexpanded @HOME@ token left in $policy_src (token misspelled?)" >&2
    exit 1
fi
mounts_json=${mounts_json//@HOME@/$HOME}
printf '%s\n' "$policy" > "$policy_rendered"
echo "==> rendered $policy_rendered (cat it to audit the exact policy being applied)"

echo "==> building $image"
docker build --build-arg HOST_HOME="$HOME" -t "$image" -f Dockerfile.dev .

echo "==> deleting '$name' (no-op if it does not exist)"
# delete is async: it returns while cleanup is pending and the name stays reserved,
# so delete and re-check until the name is gone. Whether the name is still there is
# asked of the sandbox *list*, not read out of the delete command's message: that
# wording is the CLI's to change, and an unrecognised-but-successful message used to
# mean an endless retry loop. Presence is a substring test on purpose, the
# conservative direction: a name occurring inside some other sandbox's name fails
# loudly here after the timeout, while a false "already gone" would resurface later
# as an unexplained name collision from create.
openshell sandbox delete "$name" 2>&1 || true   # idempotent; also covers an unreadable list
for _ in {1..30}; do
    if ! list_out=$(openshell sandbox list 2>&1); then
        echo "cannot list sandboxes (gateway up?) — refusing to guess whether '$name' is gone:" >&2
        printf '%s\n' "$list_out" >&2
        exit 1
    fi
    if [[ $list_out != *"$name"* ]]; then
        break
    fi
    # still reserved: ask again, quietly, and give the cleanup a second
    openshell sandbox delete "$name" >/dev/null 2>&1 || true
    sleep 1
done
if [[ ${list_out:-} == *"$name"* ]]; then
    echo "sandbox '$name' is still listed after 30 checks; 'openshell sandbox list' says:" >&2
    printf '%s\n' "$list_out" >&2
    exit 1
fi

echo "==> creating '$name' from $image"
exec openshell sandbox create \
    --name "$name" \
    --from "$image" \
    --policy "$policy_rendered" \
    --driver-config-json "$mounts_json" \
    --detach \
    "$@"
