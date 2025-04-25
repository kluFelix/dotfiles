#!/usr/bin/env bash

# Based on this: https://gist.github.com/0atman/1a5133b842f929ba4c1e195ee67599d5

# A rebuild script that commits on a successful build
set -e

# cd to your config dir
pushd /home/felix/.config/nixos/

if [ "$1" == "o" ]; then
    echo "Running offline (no pushing and pulling)"
else
echo test
    echo "Use '$0 o' to run offline without pulling and pushing"
    # Make sure the configs are up to date
    git pull origin main
fi

# Edit your config
$EDITOR /home/felix/.config/nixos/.

# Early return if no changes were detected
if git diff --quiet '*.nix' ; then
    echo "No changes detected, exiting."
    popd
    exit 0
fi

# Autoformat your nix files
alejandra . &>/dev/null \
  || ( alejandra . ; echo "formatting failed!" && exit 1)

# Shows your changes
git diff -U0 '*.nix'

echo "NixOS Rebuilding..."

# Rebuild, output simplified errors, log trackebacks
sudo nixos-rebuild switch &>nixos-switch.log || (cat nixos-switch.log | grep --color error && exit 1)

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)
# Get the system name
system_name=$(hostname)

# Commit all changes witih the generation metadata
git commit -am "$system_name - $current"
git push

# Back to where you were
popd

# Notify all OK!
notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
