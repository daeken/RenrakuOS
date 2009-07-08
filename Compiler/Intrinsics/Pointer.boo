namespace Renraku.Compiler

class PointerIntrinsics(ClassIntrinsic):
	def constructor():
		Register('Renraku.Core.Memory::Pointer[]')
		RegisterCall('get_Item', GetItem)
		RegisterCall('set_Item', SetItem)
	
	def CtorTypes(types as duck) as duck:
		yield ['conv', false, uint]
	
	def GetItem(types as duck) as duck:
		yield ['pushderef', types[0].Name]
	
	def SetItem(types as duck) as duck:
		yield ['popderef', types[0].Name]
