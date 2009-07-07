namespace Renraku.Compiler

class PointerIntrinsics(ClassIntrinsic):
	def constructor():
		Register('Renraku.Core.Memory::Pointer[]')
		RegisterCall('set_Item', SetItem)
	
	def CtorTypes(types as duck) as duck:
		yield ['conv', false, uint]
	
	def SetItem(types as duck) as duck:
		yield ['popderef', types[0]]
