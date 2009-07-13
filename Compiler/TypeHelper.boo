namespace Renraku.Compiler

import Boo.Lang.PatternMatching
import Mono.Cecil

static class TypeHelper:
	def GetSize(type as duck) as int:
		if type isa TypeDefinition:
			size = 0
			for field as FieldDefinition in type.Fields:
				subtype = field.FieldType
				if subtype isa TypeDefinition:
					size += 4
				else:
					size += GetSize(subtype)
			return size
		elif type.Name == 'Pointer`1':
			return 4
		else:
			match type.ToString():
				case 'System.Byte': return 1
				case 'System.UInt16': return 2
				case 'System.Int32' | 'System.UInt32': return 4
				otherwise:
					print type.Name
					print 'Unknown type in GetTypeSize:', type
	
	def ToRegister(letter as string, type as duck) as string:
		match GetSize(type):
			case 1: return letter + 'l'
			case 2: return letter + 'x'
			case 4: return 'e' + letter + 'x'
			otherwise:
				print 'Unknown size in ToRegister:', type, GetSize(type)
