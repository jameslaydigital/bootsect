#!/usr/bin/env bash

nasm -f bin -o stage1.bin stage_one.asm && \
nasm -f bin -o stage2.bin stage_two.asm && \
cat stage1.bin stage2.bin > raw.bin && \
(mkdir cdiso || :) && \
cp stage1.bin cdiso && cp stage2.bin cdiso && \
#mkisofs -o raw.iso -b stage1.bin cdiso/
qemu-system-x86_64 raw.bin || \
echo "COULD NOT FINISH ASSEMBLING." &>/dev/stderr
