namespace Renraku.Compiler

class InterruptIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Renraku.Kernel::InterruptManager')
		RegisterCall('Load', Load)
		RegisterCall('BuildIsrStub', BuildIsrStub)
		RegisterCall('Enable', Enable)
		RegisterCall('Disable', Disable)
		RegisterCall('get_Enabled', GetEnabled)
	
	def Load():
		yield ['popidt']
	
	def BuildIsrStub():
		yield ['buildisr']

	def Disable():
		yield ['cli']

	def Enable():
		yield ['sti']
	
	def GetEnabled():
		yield ['pushif']
