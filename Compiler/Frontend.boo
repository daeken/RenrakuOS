namespace Renraku.Compiler

import Boo.Lang.PatternMatching
import Mono.Cecil
import Mono.Cecil.Cil

static class Frontend:
	def FromAssembly(fn as string) as duck:
		assembly = AssemblyFactory.GetAssembly(fn)
		exp = ['top']
		for module as ModuleDefinition in assembly.Modules:
			for type as TypeDefinition in module.Types:
				exp.Add(FromType(type))
		
		return exp
	
	def FromType(type as TypeDefinition):
		exp = ['type', type, type.Name]
		
		for method as MethodDefinition in type.Methods:
			exp.Add(FromMethod(method))
		
		return exp
	
	def FromMethod(method as MethodDefinition):
		body = ['body']
		for inst in method.Body.Instructions:
			for elem in FromInst(inst):
				body.Add(elem)
		
		return ['method', 
				method, 
				method.Name, 
				['type', method.ReturnType.ReturnType], 
				body
			]
	
	def FromInst(inst as Instruction):
		match inst.OpCode:
			case OpCodes.Ldc_I4: yield ['push', inst.Operand]
			case OpCodes.Ldc_I4_0: yield ['push', 0]
			case OpCodes.Ldc_I4_1: yield ['push', 1]
			case OpCodes.Ldc_I4_2: yield ['push', 2]
			case OpCodes.Ldc_I4_3: yield ['push', 3]
			case OpCodes.Ldc_I4_4: yield ['push', 4]
			case OpCodes.Ldc_I4_5: yield ['push', 5]
			case OpCodes.Ldc_I4_6: yield ['push', 6]
			case OpCodes.Ldc_I4_7: yield ['push', 7]
			case OpCodes.Ldc_I4_8: yield ['push', 8]
			
			case OpCodes.Ldloc_S: yield ['pushloc', inst.Operand]
			case OpCodes.Ldloc_0: yield ['pushloc', 0]
			case OpCodes.Ldloc_1: yield ['pushloc', 1]
			case OpCodes.Stloc_0: yield ['poploc', 0]
			case OpCodes.Stloc_1: yield ['poploc', 1]
			
			case OpCodes.Conv_Ovf_I4: yield ['conv', true, int]
			case OpCodes.Conv_Ovf_U2: yield ['conv', true, ushort]
			
			case OpCodes.Or: yield ['binary', 'or']
			case OpCodes.Shl: yield ['binary', 'shl']
			
			case OpCodes.Newobj: yield ['new', inst.Operand]
			case OpCodes.Call: yield ['call', inst.Operand]
			case OpCodes.Callvirt: yield ['callvirt', inst.Operand]
			
			case OpCodes.Ret: yield ['return']
			
			otherwise:
				print 'Unhandled instruction:', inst.OpCode
