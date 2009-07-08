namespace Renraku.Compiler

import Boo.Lang.PatternMatching

static class X86:
	def Compile(assembly as duck) as duck:
		return Transform.BlockInstructions(assembly, Instruction)
	
	def Instruction(inst as duck) as duck:
		match inst[0]:
			case 'binary':
				match inst[1]:
					case 'add' | 'mul' | 'or':
						yield ['pop', 'ebx']
						yield ['pop', 'eax']
						yield [inst[1], 'eax', 'ebx']
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
					yield [mnem, 'block_' + inst[2]]
					fallthrough = inst[3]
				else:
					fallthrough = inst[2]
				yield ['jmp', 'block_' + fallthrough]
			
			case 'call':
				yield ['call', inst[1].Name]
				if len(inst[1].Parameters):
					yield ['sub', 'esp', len(inst[1].Parameters)*4]
			
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
