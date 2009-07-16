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
	
	_Bus as int
	Bus as int:
		get:
			return _Bus
		set:
			_Bus = value
	
	_Card as int
	Card as int:
		get:
			return _Card
		set:
			_Card = value
	
	def constructor():
		if not Find():
			return
		
		Hal.Register(self)
		print 'PCNet initialized.'
	
	def PrintStatus():
		print 'PCNet: OK'
