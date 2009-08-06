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
				name = TypeHelper.AnnotateName(member[1], false)
				if name not in VTable:
					VTable[name] = len(VTable)
	
	Label = 0
	def MakeLabel():
		++Label
		return '.temp_' + Label
	
	def Instruction(inst as duck) as duck:
		match inst[0]:
			case 'binary':
				match inst[1]:
					case 'add' | 'sub' | 'and' | 'or':
						yield ['pop', 'ebx']
						yield ['pop', 'eax']
						yield [inst[1], 'eax', 'ebx']
						yield ['push', 'eax']
					case 'mul':
						yield ['pop', 'ebx']
						yield ['pop', 'eax']
						yield ['mul', 'ebx']
						yield ['push', 'eax']
					case 'shl':
						yield ['pop', 'ecx']
						yield ['pop', 'eax']
						yield ['shl', 'eax', 'cl']
						yield ['push', 'eax']
					case 'shr':
						yield ['pop', 'ecx']
						yield ['pop', 'eax']
						yield ['shr', 'eax', 'cl']
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
					case '==':
						mnem = 'je'
					case '<':
						mnem = 'jl'
					case '>':
						mnem = 'jg'
					case '<=':
						mnem = 'jle'
					case '>=':
						mnem = 'jge'
					otherwise:
						print 'Unhandled branch type:', inst[1]
				
				fallthrough = inst[3]
				match mnem:
					case 'je' | 'jg' | 'jl' | 'jle' | 'jge':
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
			
			case 'buildisr':
				yield ['pop', 'ecx'] # Isr num
				yield ['pop', 'ebx'] # Idt
				
				yield ['mov', 'eax', 8]
				yield ['mul', 'ecx']
				yield ['add', 'ebx', 'eax']
				
				isrLabel = MakeLabel()
				numLabel = MakeLabel()
				noerrLabel = MakeLabel()
				retLabel = MakeLabel()
				endLabel = MakeLabel()
				yield ['mov', 'eax', isrLabel]
				yield ['mov', ['deref', 'ebx'], 'ax'] # BaseLow
				yield ['shr', 'eax', 16]
				yield ['mov', ['deref', 'ebx', 6], 'ax'] # BaseHigh
				yield ['xor', 'eax', 'eax']
				yield ['mov', ['deref', 'ebx', 4], 'al'] # Empty
				yield ['mov', 'ax', 'cs']
				yield ['mov', ['deref', 'ebx', 2], 'ax'] # Segment
				yield ['mov', 'al', 0x8E]
				yield ['mov', ['deref', 'ebx', 5], 'al'] # Flags
				
				yield ['mov', ['deref', numLabel, -4], 'ecx']
				yield ['jmp', endLabel]
				
				yield [isrLabel + ':']
				yield ['cli']
				yield ['pusha']
				yield ['mov', 'eax', ['deref', 'InterruptManager.Instance']]
				yield ['push', 'eax']
				yield ['push', 0xDEADBEEF]
				yield [numLabel + ':']
				yield ['mov', 'ebp', 'esp']
				yield ['add', 'ebp', 8]
				yield ['push', 'ebp']
				yield ['call', 'InterruptManager.Handle$System.Int32$System.Int32$Renraku.Core.Memory.Pointer_1.System.UInt32.$']
				yield ['add', 'esp', 12]
				yield ['test', 'eax', 'eax']
				yield ['jz', noerrLabel]
				yield ['popa']
				yield ['add', 'esp', 4]
				yield ['jmp', retLabel]
				yield [noerrLabel + ':']
				yield ['popa']
				yield [retLabel + ':']
				yield ['sti']
				yield ['iret']
				
				yield [endLabel + ':']
			
			case 'call':
				yield ['call', TypeHelper.AnnotateName(inst[1], true)]
				paramcount = len(inst[1].Parameters)
				if paramcount:
					yield ['add', 'esp', paramcount*4]
				
				if inst[1].ReturnType.ReturnType.ToString() != 'System.Void':
					yield ['push', 'eax']
			
			case 'callvirt':
				yield ['mov', 'eax', ['deref', 'esp', len(inst[1].Parameters)*4]]
				yield ['mov', 'eax', ['deref', 'eax']]
				yield ['call', ['deref', 'eax', cast(int, VTable[TypeHelper.AnnotateName(inst[1], false)]) * 4]]
				paramcount = len(inst[1].Parameters) + 1
				yield ['add', 'esp', paramcount*4]
				
				if inst[1].ReturnType.ReturnType.ToString() != 'System.Void':
					yield ['push', 'eax']
			
			case 'cmp':
				match inst[1]:
					case '==':
						mnem = 'sete'
					case '<':
						mnem = 'setl'
					case '>':
						mnem = 'setg'
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
				yield ['pop', 'ebx']
				yield ['push', 'edi']
				yield ['push', 'esi']
				yield ['mov', 'edi', 'ebx']
				yield ['mov', 'esi', 'eax']
				yield ['mov', 'ecx', inst[1]]
				yield ['rep', 'movsb']
				yield ['pop', 'esi']
				yield ['pop', 'edi']
			
			case 'dup':
				yield ['pop', 'eax']
				yield ['push', 'eax']
				yield ['push', 'eax']
			
			case 'in':
				yield ['pop', 'edx']
				yield ['xor', 'eax', 'eax']
				match TypeHelper.GetSize(inst[1]):
					case 1: yield ['in', 'al', 'dx']
					case 2: yield ['in', 'ax', 'dx']
					case 4: yield ['in', 'eax', 'dx']
				yield ['push', 'eax']
			
			case 'new':
				yield ['push', 'TypeDef.' + inst[1].DeclaringType.Name]
				yield ['call', 'ObjectManager.NewObj$System.UInt32$Renraku.Kernel.TypeDef$']
				yield ['add', 'esp', 4]
				if len(inst[1].Parameters):
					yield ['sub', 'esp', 4]
					for i in range(len(inst[1].Parameters)):
						yield ['mov', 'ebx', ['deref', 'esp', 4 + i*4]]
						yield ['mov', ['deref', 'esp', i*4], 'ebx']
					yield ['mov', ['deref', 'esp', len(inst[1].Parameters) * 4], 'eax']
				else:
					yield ['push', 'eax']
				yield ['call', TypeHelper.AnnotateName(inst[1], true)]
				if len(inst[1].Parameters):
					yield ['add', 'esp', len(inst[1].Parameters)*4]
			case 'newarr':
				yield ['push', TypeHelper.GetSize(inst[1])]
				yield ['push', 'VTable.Array']
				yield ['call', 'ObjectManager.NewArr$System.UInt32$System.Int32$System.Int32$System.Int32$']
				yield ['add', 'esp', 12]
				yield ['push', 'eax']
			
			case 'nop': pass
			
			case 'out':
				yield ['pop', 'eax']
				yield ['pop', 'edx']
				match TypeHelper.GetSize(inst[1]):
					case 1: yield ['out', 'dx', 'al']
					case 2: yield ['out', 'dx', 'ax']
					case 4: yield ['out', 'dx', 'eax']
			
			case 'push': yield ['push', inst[1]]
			case 'pop': yield ['add', 'esp', 4]
			
			case 'pusharg':
				yield ['mov', 'eax', ['deref', 'esi', -inst[1]*4]]
				yield ['push', 'eax']
			
			case 'popcontext':
				yield ['pop', 'edi']
			case 'pushcontext':
				yield ['push', 'edi']
			
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
				yield ['mov', ['deref', 'ebx', 'ecx', TypeHelper.GetSize(inst[1]), 8], reg]
			case 'pushelem':
				yield ['pop', 'ecx']
				yield ['pop', 'ebx']
				yield ['xor', 'eax', 'eax']
				
				reg = TypeHelper.ToRegister('a', inst[1])
				yield ['mov', reg, ['deref', 'ebx', 'ecx', TypeHelper.GetSize(inst[1]), 8]]
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
			
			case 'sti':
				yield ['sti']

			case 'cli':
				yield ['cli']
			
			case 'swap':
				yield ['pop', 'eax']
				yield ['pop', 'ebx']
				yield ['push', 'eax']
				yield ['push', 'ebx']
			
			case 'unary':
				match inst[1]:
					case 'not':
						mnem = 'not'
					otherwise:
						print 'Unknown unary op:', inst[1]
				
				yield ['pop', 'eax']
				yield [mnem, 'eax']
				yield ['push', 'eax']
			
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
		print 'org 0x00100000'
		Multiboot()
		print 'start:'
		print '\tmov esp, 0x00800000'
		print '\tcall Kernel.Main$System.Void$'
		print '\t.forever:'
		print '\t\thlt'
		print '\t\tjmp .forever'
		assembly = Transform.BlockInstructions(assembly, EmitInstruction)
		Transform.Fields(assembly, EmitField)
		Transform.Methods(assembly, EmitMethod)
		Transform.Types(assembly, EmitTypeDef)
		Transform.Interfaces(assembly, EmitTypeDef)
		
		for id, str in Strings:
			print 'str_' + id + ':'
			print '\tdd VTable.String'
			print '\tdd', len(str)
			print '\tdd .val'
			print '\t.val:'
			print '\t\tdd VTable.Array'
			print '\t\tdd', len(str)
			dstr = '\t\tdb '
			for ch in str:
				dstr += cast(int, ch) + ', 0,'
			print dstr, '0'
		
		print 'end: dd 0'
	
	def AllocString(str as string) as string:
		Strings.Add((len(Strings), str))
		return 'str_' + (len(Strings)-1)
	
	def EmitInstruction(inst as duck) as duck:
		if inst[0] == 'call':
			yield 'call ' + Deref(inst[1])
		elif inst[0] == 'lidt':
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
			ret = '[' + expr[1].ToString()
			if len(expr) >= 3:
				ret += ' + ' + expr[2].ToString()
				if len(expr) >= 4:
					ret += ' * ' + expr[3].ToString()
					if len(expr) >= 5:
						ret += ' + ' + expr[4].ToString()
			return ret + ']'
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
		_, meth as duck, _, varcount as int, _, body as duck = method
		print TypeHelper.AnnotateName(meth, true) + ':'
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
			print '\tdd VTable.' + name
			print '\tVTable.' + name + ':'
			
			names = {}
			for i in range(len(type)-3):
				member = type[i+3]
				if member[0] == 'method':
					names[TypeHelper.AnnotateName(member[1], false)] = TypeHelper.AnnotateName(member[1], true)
				elif member[0] == 'inherits':
					names[TypeHelper.AnnotateName(member[2], false)] = TypeHelper.AnnotateName(member[2], true)
			
			vtable = array(string, len(VTable))
			for ent in VTable:
				vtable[ent.Value] = ent.Key
			
			for vname in vtable:
				if vname in names:
					print '\t\tdd', names[vname]
				else:
					print '\t\tdd Kernel.Fault$System.Void$'
