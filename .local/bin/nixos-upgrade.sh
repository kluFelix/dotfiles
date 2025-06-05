#!/usr/bin/env bash

# Based on this: https://aires.fyi/blog/why-is-enabling-automatic-updates-in-nixos-hard/
# This is the client version of the script. This relies on anohter system doing
# the `nix flake update`!

cd /etc/nixos

sudo -u felix git pull

nixos-rebuild switch --upgrade --print-build-logs

sudo -u felix git push origin main
