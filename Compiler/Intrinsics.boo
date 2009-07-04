namespace Renraku.Compiler

import Boo.Lang.PatternMatching

static class Intrinsics:
	def TransformAssembly(assembly as duck) as duck:
		exp  = ['top']
		for i in range(len(assembly) - 1):
			exp.Add(TransformType(assembly[i+1]))
		return exp
	
	def TransformType(type as duck) as duck:
		exp = ['type', type[1], type[2]]
		for i in range(len(type) - 3):
			exp.Add(TransformMethod(type[i+3]))
		return exp
	
	def TransformMethod(method as duck) as duck:
		body = ['body']
		for i in range(len(method[4]) - 1):
			body.Add(TransformInstruction(method[4][i+1]))
		return ['method', method[1], method[2], method[3], body]
	
	def TransformInstruction(inst as duck) as duck:
		match inst[0]:
			case 'new':
				func = inst[1]
				if func.DeclaringType.Namespace == 'Renraku.Core.Memory' and func.DeclaringType.Name == 'Pointer`1':
					return ['conv', false, 'u4']
				return inst
			case 'callvirt':
				func = inst[1]
				if func.DeclaringType.Namespace == 'Renraku.Core.Memory' and func.DeclaringType.Name == 'Pointer`1' and func.Name == 'set_Item':
					return ['popderef']
				return inst
			otherwise:
				return inst
