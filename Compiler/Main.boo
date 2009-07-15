namespace Renraku.Compiler

import System
import System.IO

file = File.CreateText('Obj/kernel.asm')
file.AutoFlush = true
Console.SetOut(file)

# Set up intrinsics
BooRuntimeIntrinsics()
InterruptIntrinsics()
ObjectIntrinsics()
PointerIntrinsics()
ObjPointerIntrinsics()
PortIntrinsics()

cilExp = Frontend.FromAssembly(argv[0])
cilExp = Blockifier.Blockify(cilExp)
cilExp = IntrinsicRunner.Apply(cilExp)
asmExp = X86.Compile(cilExp)
X86.Emit(asmExp)
