#!/usr/bin/env bash

nasm -f bin -o raw.bin bootloader.asm &&
qemu-system-x86_64 -drive file=raw.bin,format=raw,index=0,media=disk ||
echo "COULD NOT FINISH ASSEMBLING." &>/dev/stderr
