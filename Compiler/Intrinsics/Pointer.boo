namespace Renraku.Compiler

import Boo.Lang.PatternMatching
import Mono.Cecil

class PointerIntrinsics(ClassIntrinsic):
	def constructor():
		Register('Renraku.Core.Memory::Pointer[]')
		RegisterCall('get_Item', GetItem)
		RegisterCall('set_Item', SetItem)
		RegisterCall('get_Value', GetValue)
		RegisterCall('set_Value', SetValue)
		RegisterCall('op_Addition', Addition)
	
	def CtorTypes(types as duck) as duck:
		yield ['conv', false, uint]
	
	def GetItem(types as duck) as duck:
		if types[0] isa TypeDefinition:
			yield ['push', GetTypeSize(types[0])]
			yield ['binary', 'mul', false]
			yield ['binary', 'add', false]
		else:
			yield ['pushderef', types[0].Name, true, GetTypeSize(types[0])]
	
	def SetItem(types as duck) as duck:
		if types[0] isa TypeDefinition:
			size = GetTypeSize(types[0])
			yield ['push', size]
			yield ['binary', 'mul', false]
			yield ['binary', 'add', false]
			yield ['copy', size]
		else:
			yield ['popderef', types[0].Name, true, GetTypeSize(types[0])]
	
	def GetValue(types as duck) as duck:
		if types[0] isa TypeDefinition:
			yield ['nop']
		else:
			yield ['popderef', types[0].Name, false]
	
	def SetValue(types as duck) as duck:
		if types[0] isa TypeDefinition:
			yield ['copy', GetTypeSize(types[0])]
		else:
			yield ['pushderef', types[0].Name, false]
	
	def GetTypeSize(type as duck) as int:
		if type isa TypeDefinition:
			size = 0
			for field as FieldDefinition in type.Fields:
				size += GetTypeSize(field.FieldType)
			return size
		else:
			match type.ToString():
				case 'System.Byte': return 1
				case 'System.UInt16': return 2
				case 'System.UInt32': return 4
				otherwise:
					print 'Unknown type in GetTypeSize:', type
	
	def Addition(types as duck) as duck:
		yield ['push', GetTypeSize(types[0])]
		yield ['binary', 'mul', false]
		yield ['binary', 'add', false]
