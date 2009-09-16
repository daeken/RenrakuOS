#!/bin/sh

# Cleaning
echo "Cleaning"
rm -r Obj

# Create Directories
mkdir Obj
mkdir Obj/Iso
mkdir Obj/Iso/boot
mkdir Obj/Iso/boot/grub

# Build Core
echo "Build Core"
booc -target:library -o:Obj/Core.dll Core/*.boo

# Build Compiler
echo "Build Compiler"
booc -target:exe -o:Obj/Compiler.exe Compiler/*.boo Compiler/Intrinsics/*.boo Compiler/X86/*.boo -references:Compiler/Mono.Cecil.dll,Obj/Core.dll

# Build Kernel
echo "Build Kernel"
booc -target:library -o:Obj/Kernel.Macros.dll Kernel/Macros/*.boo
booc -target:library -o:Obj/Kernel.dll Kernel/PortIO.boo Kernel/InterruptManager/*.boo Kernel/MemoryManager/*.boo Kernel/ObjectManager/*.boo Kernel/Context/*.boo Kernel/Services/*.boo Kernel/Services/*/*.boo Kernel/Services/*/*/*.boo Library/*/*.boo Library/*/*/*.boo Apps/*.boo Apps/*/*.boo Kernel/Main.boo -references:Obj/Core.dll,Obj/Kernel.Macros.dll

# Generate Assembly
echo "Generate Assembly"
mono Obj/Compiler.exe Obj/Kernel.dll

# Assemble
echo "Assemble"
nasm -o Obj/kernel.bin Obj/kernel.asm

# Copy Files
echo "Copy Files"
cp Boot/menu.iso.lst Obj/Iso/boot/grub/menu.lst
cp Boot/stage2_eltorito Obj/Iso/boot/stage2_eltorito
cp Obj/kernel.bin Obj/Iso/kernel.bin
genisoimage -R -b boot/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -o Obj/Renraku.iso Obj/Iso

