namespace Renraku.Compiler

import Boo.Lang.PatternMatching

static class X86:
	def Compile(assembly as duck) as duck:
		return Transform.BlockInstructions(assembly, Instruction)
	
	def Instruction(inst as duck) as duck:
		match inst[0]:
			case 'binary':
				match inst[1]:
					case 'add' | 'or':
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
					case '<':
						mnem = 'jl'
					otherwise:
						print 'Unhandled branch type:', inst[1]
				
				if mnem != 'jmp':
					yield ['pop', 'ebx']
					yield ['pop', 'eax']
					yield ['cmp', 'eax', 'ebx']
					yield [mnem, '.block_' + inst[2]]
					fallthrough = inst[3]
				else:
					fallthrough = inst[2]
				yield ['jmp', '.block_' + fallthrough]
			
			case 'call':
				yield ['call', inst[1].Name]
				if len(inst[1].Parameters):
					yield ['sub', 'esp', len(inst[1].Parameters)*4]
				
				if inst[1].ReturnType.ReturnType.ToString() != 'System.Void':
					yield ['push', 'eax']
			
			case 'conv':
				pass # Nop for now
			
			case 'push': yield ['push', inst[1]]
			
			case 'pusharg':
				yield ['mov', 'eax', ['deref', 'esi', -inst[1]*4]]
				yield ['push', 'eax']
			
			case 'popderef':
				yield ['pop', 'ecx']
				yield ['pop', 'ebx']
				yield ['pop', 'eax']
				
				if inst[1] == 'UInt16':
					reg = 'cx'
				else:
					print 'Unknown type for popderef:', inst[1]
				
				if reg != null:
					yield ['mov', ['deref', 'eax', 'ebx'], reg]
			
			case 'pushelem':
				yield ['pop', 'ebx']
				yield ['pop', 'eax']
				
				if inst[1] == 'Char':
					reg = 'al'
				else:
					print 'Unknown type for pushelem:', inst[1]
				
				yield ['mov', reg, ['deref', 'eax', 'ebx']]
				yield ['push', 'eax']
			
			case 'poploc':
				yield ['pop', 'eax']
				yield ['mov', ['deref', 'ebp', -inst[1]*4], 'eax']
			case 'pushloc':
				yield ['mov', 'eax', ['deref', 'ebp', -inst[1]*4]]
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
		print '\tmov esp, 0x00400000'
		print '\tcall Main'
		print '\t.forever:'
		print '\t\tjmp .forever'
		assembly = Transform.BlockInstructions(assembly, EmitInstruction)
		Transform.Methods(assembly, Method)
		
		for id, str in Strings:
			print 'str_' + id + ': db "' + str + '",0'
		
		print 'end: dd 0'
	
	def AllocString(str as string) as string:
		Strings.Add((len(Strings), str))
		return 'str_' + (len(Strings)-1)
	
	def EmitInstruction(inst as duck) as duck:
		if inst[0] == 'mov':
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
			if len(expr) == 2:
				return '[' + expr[1].ToString() + ']'
			else:
				return '[' + expr[1].ToString() + ' + ' + expr[2].ToString() + ']'
		elif expr isa List and expr[0] == 'str':
			return AllocString(expr[1])
		else:
			return expr.ToString()
	
	def Method(method as duck) as duck:
		_, meth as duck, name as string, varcount as int, _, body as duck = method
		print name + ':'
		print '\tpush ebp'
		print '\tpush esi'
		print '\tmov esi, esp'
		if len(meth.Parameters):
			print '\tadd esi,8+', len(meth.Parameters)*4
		print '\tmov ebp, esp'
		if varcount:
			print '\tsub esp,', varcount*4
		print '\tpush 0'
		print '\tjmp .block_0'
		
		for i in range(len(body)-1):
			block = body[i+1]
			id = block[1]
			print '\t.block_' + id + ':'
			for j in range(len(block)-2):
				print '\t\t' + block[j+2]
