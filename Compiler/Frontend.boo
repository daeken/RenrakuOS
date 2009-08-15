namespace Renraku.Compiler

import Boo.Lang.PatternMatching
import Mono.Cecil
import Mono.Cecil.Cil

static class Frontend:
	def FromAssembly(fn as string) as List:
		assembly = AssemblyFactory.GetAssembly(fn)
		exp = ['top']
		for module as ModuleDefinition in assembly.Modules:
			for type as TypeDefinition in module.Types:
				tyexpr = FromType(type)
				if tyexpr != null:
					exp.Add(tyexpr)
		
		return exp
	
	def FromType(type as TypeDefinition):
		if TypeHelper.IsDelegate(type):
			return
		
		if type.IsClass or type.IsValueType:
			exp = ['type', type, type.Name]
			
			names = []
			for field as FieldDefinition in type.Fields:
				names.Add(field)
				exp.Add(FromField(field))
			
			for ctor as MethodDefinition in type.Constructors:
				exp.Add(FromMethod(ctor))
			
			for method as MethodDefinition in type.Methods:
				names.Add(method.Name)
				sub = FromMethod(method)
				if sub != null:
					exp.Add(sub)
			
			if type.BaseType != null:
				basetype as TypeDefinition = null
				for subtype as TypeDefinition in type.BaseType.Module.Types:
					if subtype.FullName == type.BaseType.FullName:
						basetype = subtype
						break
				if basetype != null:
					for method as MethodDefinition in basetype.Methods:
						if method.Name not in names:
							exp.Add(['inheritsMethod', basetype, method])
					for field as FieldDefinition in basetype.Fields:
						if field.Name not in names and not field.IsStatic:
							exp.Add(['inheritsField', basetype, field])
		elif type.IsInterface:
			exp = ['interface', type, type.Name]
			
			for method as MethodDefinition in type.Methods:
				exp.Add(FromInterfaceMethod(method))
		
		return exp
	
	def FromField(field as FieldDefinition):
		return ['field', field, field.IsStatic, field.DeclaringType.Name + '.' + field.Name, field.FieldType]
	
	def FromMethod(method as MethodDefinition):
		if method.Body == null:
			return null
		else:
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
	
	def FromInterfaceMethod(method as MethodDefinition):
		return ['method', 
				method, 
				method.Name, 
				0, 
				['type', method.ReturnType.ReturnType], 
			]
	
	def FromInst(inst as Instruction):
		match inst.OpCode:
			case OpCodes.Ldnull: yield ['push', 0]
			case OpCodes.Ldc_I4: yield ['push', inst.Operand]
			case OpCodes.Ldc_I4_M1: yield ['push', -1]
			case OpCodes.Ldc_I4_0: yield ['push', 0]
			case OpCodes.Ldc_I4_1: yield ['push', 1]
			case OpCodes.Ldc_I4_2: yield ['push', 2]
			case OpCodes.Ldc_I4_3: yield ['push', 3]
			case OpCodes.Ldc_I4_4: yield ['push', 4]
			case OpCodes.Ldc_I4_5: yield ['push', 5]
			case OpCodes.Ldc_I4_6: yield ['push', 6]
			case OpCodes.Ldc_I4_7: yield ['push', 7]
			case OpCodes.Ldc_I4_8: yield ['push', 8]
			case OpCodes.Ldc_I8: yield ['push', cast(uint, cast(long, inst.Operand))]
			
			case OpCodes.Ldarga: yield ['pusharg', (inst.Operand as duck).Sequence-1]
			case OpCodes.Ldarg_0: yield ['pusharg', 0]
			case OpCodes.Ldarg_1: yield ['pusharg', 1]
			case OpCodes.Ldarg_2: yield ['pusharg', 2]
			case OpCodes.Ldarg_3: yield ['pusharg', 3]
			case OpCodes.Ldarg_S: yield ['pusharg', (inst.Operand as duck).Sequence-1]
			case OpCodes.Starg: yield ['poparg', (inst.Operand as duck).Sequence]
			
			case OpCodes.Ldelem_I1: yield ['pushelem', 'System.SByte']
			case OpCodes.Stelem_I1: yield ['popelem', 'System.SByte']
			case OpCodes.Ldelem_I2: yield ['pushelem', 'System.Int16']
			case OpCodes.Stelem_I2: yield ['popelem', 'System.Int16']
			case OpCodes.Ldelem_I4: yield ['pushelem', 'System.Int32']
			case OpCodes.Stelem_I4: yield ['popelem', 'System.Int32']
			case OpCodes.Ldelem_U1: yield ['pushelem', 'System.Byte']
			case OpCodes.Ldelem_Ref: yield ['pushelem', 'System.Object']
			case OpCodes.Stelem_Ref: yield ['popelem', 'System.Object']
			
			case OpCodes.Ldfld: yield ['pushfield', inst.Operand]
			case OpCodes.Stfld: yield ['popfield', inst.Operand]
			
			case OpCodes.Ldftn: yield ['pushfunc', inst.Operand]
			
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
			
			case OpCodes.Ldloca_S: yield ['pushloc', (inst.Operand as duck).Index]
			
			case OpCodes.Ldstr: yield ['pushstr', inst.Operand]
			
			case OpCodes.Castclass: yield ['conv', false, inst.Operand]
			case OpCodes.Conv_Ovf_I4: yield ['conv', true, int]
			case OpCodes.Conv_Ovf_I8: yield ['conv', true, long]
			case OpCodes.Conv_Ovf_U1: yield ['conv', true, byte]
			case OpCodes.Conv_Ovf_U2: yield ['conv', true, ushort]
			case OpCodes.Conv_Ovf_U4: yield ['conv', true, uint]
			case OpCodes.Box: yield ['conv', false, object]
			
			case OpCodes.Add: yield ['binary', 'add', false]
			case OpCodes.Sub: yield ['binary', 'sub', false]
			case OpCodes.Add_Ovf: yield ['binary', 'add', true]
			case OpCodes.Sub_Ovf: yield ['binary', 'sub', true]
			case OpCodes.Mul_Ovf: yield ['binary', 'mul', true]
			case OpCodes.And: yield ['binary', 'and', false]
			case OpCodes.Or: yield ['binary', 'or', false]
			case OpCodes.Shl: yield ['binary', 'shl', false]
			case OpCodes.Shr: yield ['binary', 'shr', true]
			case OpCodes.Shr_Un: yield ['binary', 'shr', false]
			case OpCodes.Xor: yield ['binary', 'xor', false]
			
			case OpCodes.Not: yield ['unary', 'not']
			
			case OpCodes.Newarr: yield ['newarr', inst.Operand]
			case OpCodes.Newobj: yield ['new', inst.Operand]
			case OpCodes.Call: yield ['call', inst.Operand]
			case OpCodes.Callvirt: yield ['callvirt', inst.Operand]
			
			case OpCodes.Ceq: yield ['cmp', '==']
			case OpCodes.Clt: yield ['cmp', '<']
			case OpCodes.Cgt: yield ['cmp', '>']
			
			case OpCodes.Dup: yield ['dup']
			case OpCodes.Pop: yield ['pop']
			case OpCodes.Nop:
				pass
			
			case OpCodes.Br: yield ['branch', null, (inst.Operand as Instruction).Offset, -1]
			case OpCodes.Br_S: yield ['branch', null, (inst.Operand as Instruction).Offset, -1]
			case OpCodes.Brfalse: yield ['branch', 'false', (inst.Operand as Instruction).Offset, NextInst(inst)]
			case OpCodes.Brtrue: yield ['branch', 'true', (inst.Operand as Instruction).Offset, NextInst(inst)]
			case OpCodes.Beq: yield ['branch', '==', (inst.Operand as Instruction).Offset, NextInst(inst)]
			case OpCodes.Blt: yield ['branch', '<', (inst.Operand as Instruction).Offset, NextInst(inst)]
			case OpCodes.Ble: yield ['branch', '<=', (inst.Operand as Instruction).Offset, NextInst(inst)]
			case OpCodes.Bgt: yield ['branch', '>', (inst.Operand as Instruction).Offset, NextInst(inst)]
			case OpCodes.Bge: yield ['branch', '>=', (inst.Operand as Instruction).Offset, NextInst(inst)]
			case OpCodes.Ret: yield ['return']
			
			otherwise:
				print 'Unhandled instruction:', inst.OpCode
	
	def NextInst(inst as Instruction):
		return inst.Next.Offset
