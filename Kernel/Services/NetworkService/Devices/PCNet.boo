namespace Renraku.Kernel

import System.Collections
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
	SendAddr as uint
	SendBuffers as (Pointer [of uint])
	RecvAddr as uint
	RecvBuffers as (Pointer [of uint])
	SendQueue as Queue
	RecvQueue as Queue
	def constructor():
		if not Find():
			return
		
		Io = GetAddressSpace(0)
		
		initBlockAddr = MemoryManager.Allocate(28+3)
		while initBlockAddr & 3 != 0:
			++initBlockAddr
		
		RecvAddr = MemoryManager.Allocate(256+15)
		while RecvAddr & 0xF != 0:
			++RecvAddr
		SendAddr = MemoryManager.Allocate(256+15)
		while SendAddr & 0xF != 0:
			++SendAddr
		
		initBlock = Pointer [of uint](initBlockAddr)
		initBlock[0] = 0x0404 << 20
		initBlock[1] = Io.Long[0] # MAC Address high
		initBlock[2] = Io.Short[4] # MAC Address low
		initBlock[5] = RecvAddr
		initBlock[6] = SendAddr
		
		RegisterLong[0] = RegisterLong[0] | 4 # STOP
		RegisterLong[1] = initBlockAddr & 0xFFFF
		RegisterLong[2] = initBlockAddr >> 16
		RegisterLong[0] = (RegisterLong[0] & ~4) | 1 | 2 | 64 # INIT | STRT | INEA
		
		while RegisterLong[0] & 0x100 == 0:
			pass
		
		BusLong[0x14] = 3
		
		SendQueue = Queue()
		RecvQueue = Queue()
		
		sendDescs = Pointer [of uint](SendAddr)
		SendBuffers = array(Pointer [of uint], 16)
		for i in range(16):
			addr = MemoryManager.Allocate(2048)
			SendBuffers[i] = Pointer [of uint](addr)
			sendDescs[2] = addr
			sendDescs += 4
		
		recvDescs = Pointer [of uint](RecvAddr)
		RecvBuffers = array(Pointer [of uint], 16)
		for i in range(16):
			addr = MemoryManager.Allocate(2048)
			RecvBuffers[i] = Pointer [of uint](addr)
			recvDescs[2] = addr
			recvDescs[1] = ((~2048) + 1) & 0x0FFF | 0x8000F000
			
			recvDescs += 4
		
		InterruptManager.AddHandler(self)
		network = cast(INetworkProvider, Context.Service['network'])
		network.AddDevice(self)
		print 'PCNet driver initialized.'
	
	def Handle(_ as Pointer [of uint]):
		status = RegisterLong[0]
		
		if status & 0x200 != 0:
			pass
		elif status & 0x4000 != 0:
			recvDescs = Pointer [of uint](RecvAddr)
			for i in range(16):
				if recvDescs[1] & 0x80000000 == 0:
					size = recvDescs[0] & 0xFFF
					rbuf = RecvBuffers[i]
					buf = array(byte, size)
					j = 0
					while j < size:
						buf[j] = rbuf[j]
						++j
					
					RecvQueue.Enqueue(buf)
					
					recvDescs[1] |= 0x80000000
				
				recvDescs += 4
		
		RegisterLong[0] = status
