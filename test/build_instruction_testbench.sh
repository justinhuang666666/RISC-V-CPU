#!/bin/bash

set -euo pipefail

rm -f riscv/**/*.hex

for f in riscv/**/*.asm
do
    riscv64-unknown-elf-as -R -march=rv32im -mabi=ilp32 -o "$f.out" "$f"
    riscv64-unknown-elf-ld -melf32lriscv -e 0xBFC00000 -Ttext 0xBFC00000 -o "$f.out.reloc" "$f.out"
    rm "$f.out"
    riscv64-unknown-elf-objcopy -O binary -j .text "$f.out.reloc" "$f.bin"
    rm "$f.out.reloc"
    od -v -An -t x1 "$f.bin" | tr -s '\n' | awk '{$1=$1};1' > "$f.hex"
    rm "$f.bin"
done

