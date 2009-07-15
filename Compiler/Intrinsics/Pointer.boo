namespace Renraku.Compiler

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
			yield ['push', TypeHelper.GetSize(types[0])]
			yield ['binary', 'mul', false]
			yield ['binary', 'add', false]
		else:
			yield ['pushderef', types[0], true, TypeHelper.GetSize(types[0])]
	
	def SetItem(types as duck) as duck:
		if types[0] isa TypeDefinition:
			size = TypeHelper.GetSize(types[0])
			yield ['push', size]
			yield ['binary', 'mul', false]
			yield ['binary', 'add', false]
			yield ['copy', size]
		else:
			yield ['popderef', types[0], true, TypeHelper.GetSize(types[0])]
	
	def GetValue(types as duck) as duck:
		if types[0] isa TypeDefinition:
			yield ['nop']
		else:
			yield ['pushderef', types[0], false]
	
	def SetValue(types as duck) as duck:
		if types[0] isa TypeDefinition:
			yield ['copy', TypeHelper.GetSize(types[0])]
		else:
			yield ['popderef', types[0], false]
	
	def Addition(types as duck) as duck:
		yield ['push', TypeHelper.GetSize(types[0])]
		yield ['binary', 'mul', false]
		yield ['binary', 'add', false]

class ObjPointerIntrinsics(ClassIntrinsic):
	def constructor():
		Register('Renraku.Core.Memory::ObjPointer[]')
		RegisterCall('get_Obj', GetObj)
	
	def CtorTypes(types as duck) as duck:
		yield ['conv', false, uint]
	
	def GetObj(types as duck) as duck:
		yield ['nop']
