namespace Renraku.Compiler

cilExp = Frontend.FromAssembly(argv[0])
cilExp = Blockifier.Blockify(cilExp)
cilExp = Intrinsics.Apply(cilExp)
pprint cilExp
