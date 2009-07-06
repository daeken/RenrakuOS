namespace Renraku.Compiler

import Boo.Lang.PatternMatching

static class Intrinsics:
	def Apply(assembly as duck) as duck:
		return Transform.BlockInstructions(assembly, Instruction)
	
	def Instruction(inst as duck) as duck:
		match inst[0]:
			case 'new':
				func = inst[1]
				if func.DeclaringType.Namespace == 'Renraku.Core.Memory' and func.DeclaringType.Name == 'Pointer`1':
					yield ['conv', false, uint]
				else:
					yield inst
			case 'callvirt':
				func = inst[1]
				if func.DeclaringType.Namespace == 'Renraku.Core.Memory' and func.DeclaringType.Name == 'Pointer`1' and func.Name == 'set_Item':
					yield ['popderef', func.DeclaringType.GenericArguments[0]]
				else:
					yield inst
			otherwise:
				yield inst
