namespace Renraku.Kernel

class PcNet(PciDevice, INetwork):
	Class as DriverClass:
		get:
			return DriverClass.Network
	
	Vendor as int:
		get:
			return 0x1022 # AMD
	
	DeviceId as int:
		get:
			return 0x2000 # PCNet
	
	[Property(Bus)]
	_Bus as int
	
	[Property(Card)]
	_Card as int
	
	def constructor():
		if not Find():
			return
		
		Configure()
		
		Hal.Register(self)
		print 'PCNet initialized.'
	
	def PrintStatus():
		print 'PCNet: OK'
