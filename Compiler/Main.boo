namespace Renraku.Compiler

cilExp = Frontend.FromAssembly(argv[0])
cilExp = Intrinsics.TransformAssembly(cilExp)
pprint cilExp
