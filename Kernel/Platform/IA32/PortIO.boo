namespace Renraku.Kernel

static class PortIO:
	def InByte(port as int) as byte:
		pass
	def OutByte(port as int, data as byte):
		pass
	
	def InShort(port as int) as ushort:
		pass
	def OutShort(port as int, data as ushort):
		pass
	
	def InLong(port as int) as uint:
		pass
	def OutLong(port as int, data as uint):
		pass
