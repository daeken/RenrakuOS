namespace Renraku.Kernel

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

macro BuildInterruptBoilerplates(idt as Expression):
	for i in range(48):
		yield [| BuildIsrStub($idt, $i) |]
