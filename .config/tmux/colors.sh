#!/usr/bin/env bash

for i in {0..255}; do
    if (( (i-1) % 6 == 0 && i != 0 )); then
        echo ""
    fi
    printf "\x1b[38;5;${i}mcolour${i}\x1b[0m  "
done
echo ""
