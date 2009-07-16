namespace Renraku.Compiler

class PortIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Renraku.Kernel::PortIO')
		RegisterCall('InByte', InByte)
		RegisterCall('OutByte', OutByte)
		RegisterCall('InShort', InShort)
		RegisterCall('OutShort', OutShort)
		RegisterCall('InLong', InLong)
		RegisterCall('OutLong', OutLong)
	
	def InByte():
		yield ['in', 'System.Byte']
	def OutByte():
		yield ['out', 'System.Byte']
	
	def InShort():
		yield ['in', 'System.UInt16']
	def OutShort():
		yield ['out', 'System.UInt16']
	
	def InLong():
		yield ['in', 'System.UInt32']
	def OutLong():
		yield ['out', 'System.UInt32']
