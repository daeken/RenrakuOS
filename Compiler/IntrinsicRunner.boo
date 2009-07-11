namespace Renraku.Compiler

import Boo.Lang.PatternMatching
import Mono.Cecil

static class IntrinsicRunner:
	def Apply(assembly as duck) as duck:
		return Transform.BlockInstructions(assembly, Instruction)
	
	def ArgsToList(args as duck) as duck:
		return [arg for arg in args]
	
	def Instruction(inst as duck) as duck:
		match inst[0]:
			case 'new':
				func = inst[1]
				found = false
				for ns, cname, targs, ifunc as duck in ClassIntrinsic.Ctors:
					if func.DeclaringType.Namespace == ns and func.DeclaringType.Name == cname:
						for elem in ifunc(ArgsToList(func.DeclaringType.GenericParameters)):
							yield elem
						found = true
						break
				if not found:
					yield inst
			case 'call':
				func = inst[1]
				found = false
				for ns, cname, targs, name, ifunc as duck in ClassIntrinsic.Calls:
					if func.DeclaringType.Namespace == ns and func.DeclaringType.Name == cname and func.Name == name:
						if func.DeclaringType isa GenericInstanceType:
							for elem in ifunc(ArgsToList(func.DeclaringType.GenericArguments)):
								yield elem
						else:
							for elem in ifunc():
								yield elem
						found = true
						break
				if not found:
					yield inst
			case 'callvirt':
				func = inst[1]
				found = false
				for ns, cname, targs, name, ifunc as duck in ClassIntrinsic.Calls:
					if func.DeclaringType.Namespace == ns and func.DeclaringType.Name == cname and func.Name == name:
						if func.DeclaringType isa GenericInstanceType:
							for elem in ifunc(ArgsToList(func.DeclaringType.GenericArguments)):
								yield elem
						else:
							for elem in ifunc():
								yield elem
						found = true
						break
				if not found:
					yield inst
			otherwise:
				yield inst
