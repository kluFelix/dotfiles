#!/usr/bin/env bash

# Based on this: https://aires.fyi/blog/why-is-enabling-automatic-updates-in-nixos-hard/

cd /etc/nixos

sudo -u felix git pull

sudo -u felix nix flake update --commit-lock-file
#sudo -u felix git stage flake.lock
#sudo -u felix git commit  -am "gml - automatic upgrade"

nixos-rebuild boot --upgrade --print-build-logs

sudo -u felix git push origin main

sleep 120

reboot
