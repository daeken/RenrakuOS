namespace Renraku.Compiler

class PortIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Renraku.Kernel::PortIO')
		RegisterCall('InByte', InByte)
		RegisterCall('OutByte', OutByte)
	
	def InByte():
		yield ['in', 'System.Byte']
	def OutByte():
		yield ['out', 'System.Byte']
