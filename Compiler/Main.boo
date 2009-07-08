namespace Renraku.Compiler

# Set up intrinsics
PointerIntrinsics()
StringIntrinsics()

cilExp = Frontend.FromAssembly(argv[0])
cilExp = Blockifier.Blockify(cilExp)
cilExp = IntrinsicRunner.Apply(cilExp)
asmExp = X86.Compile(cilExp)
pprint asmExp
