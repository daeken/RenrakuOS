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
				yield ['mov', 'eax', ['deref', 'ebp', -inst[1]*4-4]]
				yield ['push', 'eax']
			
			case 'popderef':
				yield ['pop', 'ebx']
				yield ['pop', 'eax']
				
				if inst[1] == 'UInt16':
					reg = 'bx'
				else:
					print 'Unknown type for popderef:', inst[1]
				
				if reg != null:
					yield ['mov', ['deref', 'eax'], reg]
			
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
				yield ['mov', ['deref', 'ebp', inst[1]*4], 'eax']
			case 'pushloc':
				yield ['mov', 'eax', ['deref', 'ebp', inst[1]*4]]
				yield ['push', 'eax']
			
			case 'pushstr':
				yield ['mov', 'eax', ['str', inst[1]]]
				yield ['push', 'eax']
			
			case 'return':
				yield ['pop', 'eax']
				yield ['mov', 'esp', 'ebp']
				yield ['ret']
			
			otherwise:
				print 'Unhandled instruction:', inst[0]
	
	Strings as List = []
	def Emit(assembly as duck) as duck:
		print 'bits 32'
		print 'jmp Main'
		assembly = Transform.BlockInstructions(assembly, EmitInstruction)
		Transform.Methods(assembly, Method)
		
		for id, str in Strings:
			print 'str_' + id + ': db "' + str + '",0'
	
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
		_, _, name as string, varcount as int, _, body as duck = method
		print name + ':'
		print '\tmov ebp, esp'
		if varcount:
			print '\tadd esp,', varcount*4
		print '\tjmp .block_0'
		
		for i in range(len(body)-1):
			block = body[i+1]
			id = block[1]
			print '\t.block_' + id + ':'
			for j in range(len(block)-2):
				print '\t\t' + block[j+2]
