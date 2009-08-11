namespace Renraku.Compiler

import System
import System.IO

file = File.CreateText('Obj/kernel.asm')
file.AutoFlush = true
Console.SetOut(file)

# Set up intrinsics
BooRuntimeIntrinsics()
ContextIntrinsics()
InterruptIntrinsics()
LogoIntrinsics()
ObjectIntrinsics()
PointerIntrinsics()
ObjPointerIntrinsics()
PortIntrinsics()

cilExp = ['top']

for arg in argv: 
	cilExp += Frontend.FromAssembly(arg)[1:]

cilExp = Blockifier.Blockify(cilExp)
cilExp = IntrinsicRunner.Apply(cilExp)
asmExp = X86.Compile(cilExp)
X86.Emit(asmExp)
