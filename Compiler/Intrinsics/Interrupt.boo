namespace Renraku.Compiler

class InterruptIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Renraku.Kernel::InterruptManager')
		RegisterCall('Load', Load)
	
	def Load():
		yield ['popidt']
