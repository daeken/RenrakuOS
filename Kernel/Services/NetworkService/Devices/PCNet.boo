namespace Renraku.Kernel

class PCNet(INetworkDevice, PciDevice):
	override VendorId:
		get:
			return 0x1022
	
	override DeviceId:
		get:
			return 0x2000
	
	def constructor():
		if not Find():
			return
		
		network = cast(INetworkProvider, Context.Service['network'])
		network.AddDevice(self)
		print 'PCNet driver initialized.'
