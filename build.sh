#!/usr/bin/env bash

nasm -f bin -o stage1.bin stage_one.asm && \
nasm -f bin -o stage2.bin stage_two.asm && \
cat stage1.bin stage2.bin > raw.bin && \
qemu-system-x86_64 -drive file=raw.bin,format=raw,index=0,media=disk || \
echo "COULD NOT FINISH ASSEMBLING." &>/dev/stderr
