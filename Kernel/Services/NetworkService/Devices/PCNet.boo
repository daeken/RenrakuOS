namespace Renraku.Kernel

import System.Collections
import System.Net
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
	
	override Mac:
		get:
			return _Mac
	
	override Ip:
		get:
			return _Ip
		set:
			_Ip = value
	
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
	
	Net as INetworkProvider
	Io as IAddressSpace
	SendAddr as uint
	SendBuffers as (Pointer [of byte])
	SendOff as uint
	RecvAddr as uint
	RecvBuffers as (Pointer [of byte])
	SendQueue as Queue
	_Mac as (byte)
	_Ip as IPAddress
	def constructor():
		if not Find():
			return
		
		Net = cast(INetworkProvider, Context.Service['network'])
		
		Io = GetAddressSpace(0)
		
		Enable()
		
		Io.Long[0x10] = 0
		
		initBlockAddr = MemoryManager.Allocate(28+3)
		while initBlockAddr & 3 != 0:
			++initBlockAddr
		
		RecvAddr = MemoryManager.Allocate(256+15)
		while RecvAddr & 0xF != 0:
			++RecvAddr
		SendAddr = MemoryManager.Allocate(256+15)
		while SendAddr & 0xF != 0:
			++SendAddr
		SendOff = 0
		
		initBlock = Pointer [of uint](initBlockAddr)
		initBlock[0] = 0x0404 << 20
		initBlock[1] = Io.Long[0] # MAC Address high
		initBlock[2] = Io.Short[4] # MAC Address low
		initBlock[5] = RecvAddr
		initBlock[6] = SendAddr
		
		_Mac = array(byte, 6)
		high = Io.Long[0]
		_Mac[0] = high & 0xFF
		_Mac[1] = (high >> 8) & 0xFF
		_Mac[2] = (high >> 16) & 0xFF
		_Mac[3] = high >> 24
		low = Io.Short[4]
		_Mac[4] = low & 0xFF
		_Mac[5] = low >> 8
		
		RegisterLong[1] = initBlockAddr & 0xFFFF
		RegisterLong[2] = initBlockAddr >> 16
		
		BusLong[0x14] = 3
		
		SendQueue = Queue()
		
		sendDescs = Pointer [of uint](SendAddr)
		SendBuffers = array(Pointer [of byte], 16)
		for i in range(16):
			addr = MemoryManager.Allocate(2048)
			SendBuffers[i] = Pointer [of byte](addr)
			sendDescs[2] = addr
			sendDescs += 4
		
		recvDescs = Pointer [of uint](RecvAddr)
		RecvBuffers = array(Pointer [of byte], 16)
		for i in range(16):
			addr = MemoryManager.Allocate(2048)
			RecvBuffers[i] = Pointer [of byte](addr)
			recvDescs[2] = addr
			recvDescs[1] = (((~2048) + 1) & 0x0FFF) | 0x8000F000
			
			recvDescs += 4
		
		RegisterLong[0] = 1 | 2 | 64 # INIT | STRT | INEA
		
		_Ip = IPAddress.Parse('0.0.0.0')
		
		InterruptManager.AddHandler(self)
		network = cast(INetworkProvider, Context.Service['network'])
		network.AddDevice(self)
		print 'PCNet driver initialized.'
	
	def Handle(_ as Pointer [of uint]):
		status = RegisterLong[0]
		
		if status & 0x200 != 0:
			if SendQueue.Count > 0:
				data = cast((byte), SendQueue.Peek())
				if SendData(data):
					SendQueue.Dequeue()
		
		if status & 0x400 != 0:
			recvDescs = Pointer [of uint](RecvAddr)
			for i in range(16):
				if recvDescs[1] & 0x80000000 == 0:
					size = recvDescs[0] & 0xFFF
					rbuf = RecvBuffers[i]
					tbuf = array(byte, size)
					j = 0
					while j < size:
						tbuf[j] = rbuf[j]
						++j
					
					Net.Recv(tbuf)
					
					recvDescs[1] |= 0x80000000
				
				recvDescs += 4
		
		RegisterLong[0] = status
	
	def SendData(data as (byte)) as bool:
		ret = false
		sendDesc = Pointer [of uint](SendAddr + (SendOff << 4))
		
		if sendDesc[1] & 0x80000000 == 0:
			buf = SendBuffers[SendOff]
			ti = 0
			while ti < data.Length:
				buf[ti] = data[ti]
				++ti
			
			length = data.Length
			sendDesc[1] = (((~length) + 1) & 0x0FFF) | 0x8300F000
			
			ret = true
		
		if ++SendOff == 16:
			SendOff = 0
		return ret
	
	def Send(data as (byte)):
		if not SendData(data):
			SendQueue.Enqueue(data)
