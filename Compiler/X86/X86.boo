namespace Renraku.Compiler

import Boo.Lang.PatternMatching

static class X86:
	def Compile(assembly as duck) as duck:
		Transform.Types(assembly, BuildVTable)
		Transform.Interfaces(assembly, BuildVTable)
		return Transform.BlockInstructions(assembly, Instruction)
	
	VTable = {}
	def BuildVTable(type as duck) as duck:
		for i in range(len(type)-3):
			member = type[i+3]
			if member[0] == 'method':
				if member[1].Name not in VTable:
					VTable[member[1].Name] = len(VTable)
	
	def Instruction(inst as duck) as duck:
		match inst[0]:
			case 'binary':
				match inst[1]:
					case 'add' | 'sub' | 'or':
						yield ['pop', 'ebx']
						yield ['pop', 'eax']
						yield [inst[1], 'eax', 'ebx']
						yield ['push', 'eax']
					case 'mul':
						yield ['pop', 'ebx']
						yield ['pop', 'eax']
						yield ['mul', 'ebx']
						yield ['push', 'eax']
					otherwise:
						print 'Unhandled binary operator:', inst[1]
			
			case 'branch':
				match inst[1]:
					case null:
						mnem = 'jmp'
					case 'false':
						mnem = 'jz'
					case 'true':
						mnem = 'jnz'
					case '<':
						mnem = 'jl'
					otherwise:
						print 'Unhandled branch type:', inst[1]
				
				fallthrough = inst[3]
				match mnem:
					case 'jl':
						yield ['pop', 'ebx']
						yield ['pop', 'eax']
						yield ['cmp', 'eax', 'ebx']
						yield [mnem, '.block_' + inst[2]]
					case 'jz' | 'jnz':
						yield ['pop', 'eax']
						yield ['test', 'eax', 'eax']
						yield [mnem, '.block_' + inst[2]]
					otherwise:
						fallthrough = inst[2]
				yield ['jmp', '.block_' + fallthrough]
			
			case 'call':
				yield ['call', inst[1].DeclaringType.Name + '.' + inst[1].Name]
				paramcount = len(inst[1].Parameters)
				if paramcount:
					yield ['sub', 'esp', paramcount*4]
				
				if inst[1].ReturnType.ReturnType.ToString() != 'System.Void':
					yield ['push', 'eax']
			
			case 'callvirt':
				yield ['mov', 'eax', ['deref', 'esp', len(inst[1].Parameters)*4]]
				yield ['mov', 'eax', ['deref', 'eax']]
				yield ['mov', 'eax', ['deref', 'eax', cast(int, VTable[inst[1].Name]) * 4]]
				yield ['call', 'eax']
				paramcount = len(inst[1].Parameters) + 1
				yield ['sub', 'esp', paramcount*4]
				
				if inst[1].ReturnType.ReturnType.ToString() != 'System.Void':
					yield ['push', 'eax']
			
			case 'cmp':
				match inst[1]:
					case '==':
						mnem = 'setz'
					case '<':
						mnem = 'setc'
					otherwise:
						print 'Unknown cmp type:', inst[1]
				yield ['pop', 'ecx']
				yield ['pop', 'ebx']
				yield ['xor', 'eax', 'eax']
				yield ['cmp', 'ebx', 'ecx']
				yield [mnem, 'al']
				yield ['push eax']
			
			case 'conv':
				pass # Nop for now
			
			case 'copy':
				yield ['pop', 'eax']
				yield ['pop', 'edi']
				yield ['push', 'esi']
				yield ['mov', 'esi', 'eax']
				yield ['mov', 'ecx', inst[1]]
				yield ['rep', 'movsb']
				yield ['pop', 'esi']
			
			case 'dup':
				yield ['pop', 'eax']
				yield ['push', 'eax']
				yield ['push', 'eax']
			
			case 'new':
				yield ['push', 'TypeDef.' + inst[1].DeclaringType.Name]
				yield ['call', 'ObjectManager.NewObj']
				yield ['add', 'esp', 4]
				yield ['push', 'eax']
				yield ['call', inst[1].DeclaringType.Name + '.' + inst[1].Name]
			case 'newarr':
				yield ['push', 'TypeDef.' + inst[1].Name]
				yield ['call', 'ObjectManager.NewArr']
				yield ['add', 'esp', 8]
				yield ['push', 'eax']
			
			case 'nop': pass
			
			case 'push': yield ['push', inst[1]]
			case 'pop': yield ['add', 'esp', 4]
			
			case 'pusharg':
				yield ['mov', 'eax', ['deref', 'esi', -inst[1]*4]]
				yield ['push', 'eax']
			
			case 'popderef':
				isIndexed = inst[2]
				yield ['pop', 'ecx']
				
				if isIndexed:
					yield ['pop', 'ebx']
				yield ['pop', 'eax']
				
				reg = TypeHelper.ToRegister('c', inst[1])
				if isIndexed:
					yield ['mov', ['deref', 'eax', 'ebx', inst[3]], reg]
				else:
					yield ['mov', ['deref', 'eax'], reg]
			case 'pushderef':
				isIndexed = inst[2]
				yield ['xor', 'ecx', 'ecx']
				
				if isIndexed:
					yield ['pop', 'ebx']
				yield ['pop', 'eax']
				
				reg = TypeHelper.ToRegister('c', inst[1])
				if isIndexed:
					yield ['mov', reg, ['deref', 'eax', 'ebx', inst[3]]]
				else:
					yield ['mov', reg, ['deref', 'eax']]
				yield ['push', 'ecx']
			
			case 'popelem':
				yield ['pop', 'eax']
				yield ['pop', 'ecx']
				yield ['pop', 'ebx']
				
				reg = TypeHelper.ToRegister('a', inst[1])
				yield ['mov', reg, ['deref', 'ebx', 'ecx']]
				yield ['push', 'eax']
			case 'pushelem':
				yield ['pop', 'ecx']
				yield ['pop', 'ebx']
				yield ['xor', 'eax', 'eax']
				
				reg = TypeHelper.ToRegister('a', inst[1])
				
				yield ['mov', reg, ['deref', 'ebx', 'ecx']]
				yield ['push', 'eax']
			
			case 'popfield':
				if inst[1].DeclaringType.IsValueType:
					off = 0
				else:
					off = 4
				for field as duck in inst[1].DeclaringType.Fields:
					if field.IsStatic:
						continue
					if field == inst[1]:
						break
					else:
						off += TypeHelper.GetSize(field.FieldType)
				
				yield ['pop', 'ebx']
				yield ['pop', 'eax']
				yield ['mov', ['deref', 'eax', off], TypeHelper.ToRegister('b', inst[1].FieldType)]
			case 'pushfield':
				if inst[1].DeclaringType.IsValueType:
					off = 0
				else:
					off = 4
				for field as duck in inst[1].DeclaringType.Fields:
					if field.IsStatic:
						continue
					if field == inst[1]:
						break
					else:
						off += TypeHelper.GetSize(field.FieldType)
				
				yield ['pop', 'eax']
				yield ['xor', 'ebx', 'ebx']
				yield ['mov', TypeHelper.ToRegister('b', inst[1].FieldType), ['deref', 'eax', off]]
				yield ['push', 'ebx']
			
			case 'popidt':
				yield ['pop', 'eax']
				yield ['lidt', ['deref', 'eax']]
			
			case 'popstaticfield':
				yield ['pop', 'eax']
				yield ['mov', ['deref', inst[1].DeclaringType.Name + '.' + inst[1].Name], 'eax']
			case 'pushstaticfield':
				yield ['mov', 'eax', ['deref', inst[1].DeclaringType.Name + '.' + inst[1].Name]]
				yield ['push', 'eax']
			
			case 'poploc':
				yield ['pop', 'eax']
				yield ['mov', ['deref', 'ebp', -inst[1]*4-4], 'eax']
			case 'pushloc':
				yield ['mov', 'eax', ['deref', 'ebp', -inst[1]*4-4]]
				yield ['push', 'eax']
			
			case 'pushstr':
				yield ['mov', 'eax', ['str', inst[1]]]
				yield ['push', 'eax']
			
			case 'return':
				yield ['pop', 'eax']
				yield ['mov', 'esp', 'ebp']
				yield ['pop esi']
				yield ['pop ebp']
				yield ['ret']
			
			case 'swap':
				yield ['pop', 'eax']
				yield ['pop', 'ebx']
				yield ['push', 'eax']
				yield ['push', 'ebx']
			
			otherwise:
				print 'Unhandled instruction:', inst[0]
	
	def Multiboot():
		print 'align 4'
		print 'dd 0x1BADB002' # Magic
		print 'dd 0x10003'
		print 'dd -(0x1BADB002 + 0x10003)'
		
		# Memory header
		print 'dd 0x100000' # header_addr == 1MB
		print 'dd 0x100000' # load_addr == 1MB
		print 'dd end+4' # load_end_addr == none
		print 'dd end+4' # bss_end_addr == none
		print 'dd start'
	
	Strings as List = []
	def Emit(assembly as duck) as duck:
		print 'bits 32'
		print 'org 0x100000'
		Multiboot()
		print 'start:'
		print '\tmov esp, 0x00800000'
		print '\tcall Kernel.Main'
		print '\t.forever:'
		print '\t\tjmp .forever'
		assembly = Transform.BlockInstructions(assembly, EmitInstruction)
		Transform.Fields(assembly, EmitField)
		Transform.Methods(assembly, EmitMethod)
		Transform.Types(assembly, EmitTypeDef)
		Transform.Interfaces(assembly, EmitTypeDef)
		
		for id, str in Strings:
			print 'str_' + id + ': db "' + str + '",0'
		
		print 'end: dd 0'
	
	def AllocString(str as string) as string:
		Strings.Add((len(Strings), str))
		return 'str_' + (len(Strings)-1)
	
	def EmitInstruction(inst as duck) as duck:
		if inst[0] == 'lidt':
			yield 'lidt ' + Deref(inst[1])
		elif inst[0] == 'mov':
			_, a, b = inst
			yield 'mov ' + Deref(a) + ', ' + Deref(b)
		elif inst[0] == 'push':
			yield 'push ' + Deref(inst[1])
		elif len(inst) == 1:
			yield inst[0]
		else:
			ret as string = inst[0] + ' '
			for i in range(len(inst)-1):
				ret += inst[i+1] + ', '
			yield ret[:-2]
	
	def Deref(expr as duck) as string:
		if expr isa List and expr[0] == 'deref':
			match len(expr):
				case 2:
					return '[' + expr[1].ToString() + ']'
				case 3:
					return '[' + expr[1].ToString() + ' + ' + expr[2].ToString() + ']'
				case 4:
					return '[' + expr[1].ToString() + ' + ' + expr[2].ToString() + ' * ' + expr[3].ToString() + ']'
		elif expr isa List and expr[0] == 'str':
			return AllocString(expr[1])
		elif expr == null:
			return 'null'
		else:
			return expr.ToString()
	
	def EmitField(field as duck) as duck:
		if not field[1]:
			return
		
		print field[2], ': dd 0'
	
	def EmitMethod(method as duck) as duck:
		_, meth as duck, name as string, varcount as int, _, body as duck = method
		print meth.DeclaringType.Name + '.' + name + ':'
		print '\tpush ebp'
		print '\tpush esi'
		print '\tmov esi, esp'
		paramcount = len(meth.Parameters)
		if meth.This != null:
			paramcount++
		if paramcount > 0:
			print '\tadd esi,8+', paramcount*4
		print '\tmov ebp, esp'
		if varcount:
			print '\tsub esp,', varcount*4+4
		print '\tpush 0'
		print '\tjmp .block_0'
		
		for i in range(len(body)-1):
			block = body[i+1]
			id = block[1]
			print '\t.block_' + id + ':'
			for j in range(len(block)-2):
				print '\t\t' + block[j+2]
	
	def EmitTypeDef(type as duck) as duck:
		isInterface = type[0] == 'interface'
		
		name as string = type[2]
		if name == '<Module>':
			return
		
		print 'TypeDef.' + name + ':'
		
		size = 0
		for i in range(len(type)-3):
			member = type[i+3]
			if member[0] == 'field' and not member[1]:
				size += TypeHelper.GetSize(member[3])
		print '\tdd', size
		
		if isInterface:
			print '\tdd', 0
		else:
			print '\tdd .vtable'
			print '\t.vtable:'
			
			names = []
			for i in range(len(type)-3):
				member = type[i+3]
				if member[0] == 'method':
					names.Add(member[2])
			
			vtable = array(string, len(VTable))
			for ent in VTable:
				vtable[ent.Value] = ent.Key
			
			for vname in vtable:
				if vname in names:
					print '\t\tdd', name + '.' + vname
				else:
					print '\t\tdd 0'
