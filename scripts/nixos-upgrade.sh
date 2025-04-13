#!/usr/bin/env bash

nix-env --delete-generations +5
nix-channel --update
nixos-rebuild switch --upgrade
nix-collect-garbage
