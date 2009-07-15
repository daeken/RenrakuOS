namespace Renraku.Compiler

class PortIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Renraku.Kernel::PortIO')
		RegisterCall('OutByte', OutByte)
	
	def OutByte():
		yield ['out', 'System.Byte']
