namespace Renraku.Compiler

class InterruptIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Renraku.Kernel::InterruptManager')
		RegisterCall('Load', Load)
		RegisterCall('BuildIsrStub', BuildIsrStub)
		RegisterCall('Enable', Enable)
	
	def Load():
		yield ['popidt']
	
	def BuildIsrStub():
		yield ['buildisr']
	
	def Enable():
		yield ['sti']
