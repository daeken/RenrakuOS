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
		
		for field as FieldDefinition in type.Fields:
			exp.Add(FromField(field))
		
		for method as MethodDefinition in type.Methods:
			exp.Add(FromMethod(method))
		
		return exp
	
	def FromField(field as FieldDefinition):
		return ['field', field.Name, field.FieldType]
	
	def FromMethod(method as MethodDefinition):
		body = ['body']
		for inst as Instruction in method.Body.Instructions:
			iblock = ['inst', inst.Offset]
			for elem in FromInst(inst):
				iblock.Add(elem)
			body.Add(iblock)
		
		return ['method', 
				method, 
				method.Name, 
				method.Body.Variables.Count, 
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
			
			case OpCodes.Ldarg_0: yield ['pusharg', 0]
			case OpCodes.Ldarg_1: yield ['pusharg', 1]
			case OpCodes.Ldarg_2: yield ['pusharg', 2]
			
			case OpCodes.Ldsfld: yield ['pushstaticfield', inst.Operand]
			case OpCodes.Stsfld: yield ['popstaticfield', inst.Operand]
			
			case OpCodes.Ldloc_S: yield ['pushloc', (inst.Operand as duck).Index]
			case OpCodes.Ldloc_0: yield ['pushloc', 0]
			case OpCodes.Ldloc_1: yield ['pushloc', 1]
			case OpCodes.Ldloc_2: yield ['pushloc', 2]
			case OpCodes.Ldloc_3: yield ['pushloc', 3]
			case OpCodes.Stloc_0: yield ['poploc', 0]
			case OpCodes.Stloc_1: yield ['poploc', 1]
			case OpCodes.Stloc_2: yield ['poploc', 2]
			case OpCodes.Stloc_3: yield ['poploc', 3]
			case OpCodes.Stloc_S: yield ['poploc', (inst.Operand as duck).Index]
			
			case OpCodes.Ldstr: yield ['pushstr', inst.Operand]
			
			case OpCodes.Conv_Ovf_I4: yield ['conv', true, int]
			case OpCodes.Conv_Ovf_U2: yield ['conv', true, ushort]
			
			case OpCodes.Add: yield ['binary', 'add', false]
			case OpCodes.Add_Ovf: yield ['binary', 'add', true]
			case OpCodes.Mul_Ovf: yield ['binary', 'mul', true]
			case OpCodes.Or: yield ['binary', 'or', false]
			case OpCodes.Shl: yield ['binary', 'shl', false]
			
			case OpCodes.Newobj: yield ['new', inst.Operand]
			case OpCodes.Call: yield ['call', inst.Operand]
			case OpCodes.Callvirt: yield ['callvirt', inst.Operand]
			
			case OpCodes.Ceq: yield ['cmp', '==']
			case OpCodes.Clt: yield ['cmp', '<']
			
			case OpCodes.Br: yield ['branch', null, (inst.Operand as Instruction).Offset, -1]
			case OpCodes.Brfalse: yield ['branch', 'false', (inst.Operand as Instruction).Offset, NextInst(inst)]
			case OpCodes.Blt: yield ['branch', '<', (inst.Operand as Instruction).Offset, NextInst(inst)]
			case OpCodes.Ret: yield ['return']
			
			otherwise:
				print 'Unhandled instruction:', inst.OpCode
	
	def NextInst(inst as Instruction):
		return inst.Next.Offset
