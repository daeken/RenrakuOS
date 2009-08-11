namespace Renraku.Kernel

import Renraku.Core.Memory

class PCNet(IInterruptHandler, INetworkDevice, PciDevice):
	override VendorId:
		get:
			return 0x1022
	
	override DeviceId:
		get:
			return 0x2000
	
	override InterruptNumber:
		get:
			return 32+InterruptLine
	
	RegisterLong [addr as int] as uint:
		get:
			Io.Long[0x14] = addr
			return Io.Long[0x10]
		set:
			Io.Long[0x14] = addr
			Io.Long[0x10] = value
	
	BusLong [addr as int] as uint:
		get:
			Io.Long[0x14] = addr
			return Io.Long[0x1C]
		set:
			Io.Long[0x14] = addr
			Io.Long[0x1C] = value
	
	Io as IAddressSpace
	def constructor():
		if not Find():
			return
		
		Io = GetAddressSpace(0)
		
		initBlockAddr = MemoryManager.Allocate(28+3)
		while initBlockAddr & 3 != 0:
			++initBlockAddr
		
		recvAddr = MemoryManager.Allocate(256+15)
		while recvAddr & 0xF != 0:
			++recvAddr
		sendAddr = MemoryManager.Allocate(256+15)
		while sendAddr & 0xF != 0:
			++sendAddr
		
		initBlock = Pointer [of uint](initBlockAddr)
		initBlock[0] = 0x0404 << 20
		initBlock[1] = Io.Long[0] # MAC Address high
		initBlock[2] = Io.Short[4] # MAC Address low
		initBlock[5] = recvAddr
		initBlock[6] = sendAddr
		
		RegisterLong[0] = RegisterLong[0] | 4 # STOP
		RegisterLong[1] = initBlockAddr & 0xFFFF
		RegisterLong[2] = initBlockAddr >> 16
		RegisterLong[0] = (RegisterLong[0] & ~4) | 1 | 2 | 64 # INIT | STRT | INEA
		
		while RegisterLong[0] & 0x100 == 0:
			pass
		
		InterruptManager.AddHandler(self)
		network = cast(INetworkProvider, Context.Service['network'])
		network.AddDevice(self)
		print 'PCNet driver initialized.'
	
	def Handle(_ as Pointer [of uint]):
		pass
