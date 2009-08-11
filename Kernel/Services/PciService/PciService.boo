namespace Renraku.Kernel

import Renraku.Core.Memory

interface IAddressSpace:
	Short [off as uint] as ushort:
		get:
			pass
		set:
			pass
	
	Long [off as uint] as uint:
		get:
			pass
		set:
			pass

class MemoryAddressSpace(IAddressSpace):
	Short [off as uint]:
		get:
			return Pointer [of ushort](Address + off).Value
		set:
			Pointer [of ushort](Address + off).Value = value
	
	Long [off as uint]:
		get:
			return Pointer [of uint](Address + off).Value
		set:
			Pointer [of uint](Address + off).Value = value
	
	Address as int
	def constructor(address as int):
		Address = address

class IOAddressSpace(IAddressSpace):
	Short [off as uint]:
		get:
			return PortIO.InShort(Address + off)
		set:
			PortIO.OutShort(Address + off, value)
	
	Long [off as uint]:
		get:
			return PortIO.InLong(Address + off)
		set:
			PortIO.OutLong(Address + off, value)
	
	Address as int
	def constructor(address as int):
		Address = address

class PciDevice:
	virtual VendorId as int:
		get:
			return 0xFFFF
	
	virtual DeviceId as int:
		get:
			return 0xFFFF
	
	Bus as int
	Card as int
	
	InterruptLine:
		get:
			return PciService.ReadByte(Card, Bus, 0x3C)
	
	def Find():
		if PciService.Type == 1:
			for bus in range(16):
				for card in range(32):
					tmp = PciService.ReadLong(card, bus, 0)
					if VendorId == (tmp & 0xFFFF) and DeviceId == (tmp >> 16):
						Bus = bus
						Card = card
						return true
		elif PciService.Type == 2:
			PortIO.OutShort(0xCF8, 0x80)
			PortIO.OutShort(0xCFA, 0)
			for card in range(16):
				tmp = PciService.ReadLong(card, 0, 0)
				if VendorId == (tmp & 0xFFFF) and DeviceId == (tmp >> 16):
					Bus = 0
					Card = card
					return true
		
		return false
	
	def GetAddressSpace(num as int) as IAddressSpace:
		num = 0x10 + num << 2
		val = PciService.ReadLong(Card, Bus, num)
		
		if val & 1 == 0:
			return MemoryAddressSpace(val & 0xFFFFFFF0)
		else:
			return IOAddressSpace(val & 0xFFFFFFFC)

class PciService(IService):
	override ServiceId:
		get:
			return 'pci'
	
	public static Type as int
	
	def constructor():
		PortIO.OutShort(0xCF8, 0)
		PortIO.OutShort(0xCFA, 0)
		
		if PortIO.InShort(0xCF8) == 0 and PortIO.InShort(0xCFA) == 0:
			Type = 2
			print 'PCI type 2 initialized.'
		else:
			tmp = PortIO.InLong(0xCF8)
			PortIO.OutLong(0xCF8, 0x80000000)
			if PortIO.InLong(0xCF8) == 0x80000000:
				Type = 1
				print 'PCI type 1 initialized.'
			else:
				Type = 0
			PortIO.OutLong(0xCF8, tmp)
		
		Context.Register(self)
	
	def Scan():
		if Type == 1:
			for bus in range(16):
				for card in range(32):
					tmp = ReadLong(card, bus, 0)
					if (tmp & 0xFFFF) != 0xFFFF and (tmp >> 16) != 0xFFFF:
						PrintDevice(tmp)
		elif Type == 2:
			PortIO.OutShort(0xCF8, 0x80)
			PortIO.OutShort(0xCFA, 0)
			for card in range(16):
				tmp = ReadLong(card, 0, 0)
				if (tmp & 0xFFFF) != 0xFFFF and (tmp >> 16) != 0xFFFF:
					PrintDevice(tmp)
	
	static def ReadByte(card as int, bus as int, index as int):
		if Type == 1:
			PortIO.OutLong(0xCF8, 0x80000000 | (card << 11) | (bus << 16) | index)
			return PortIO.InByte(0xCFC)
		elif Type == 2:
			return PortIO.InByte(0xC000 | (card << 8) | index)
		else:
			return 0
	
	static def ReadShort(card as int, bus as int, index as int):
		if Type == 1:
			PortIO.OutLong(0xCF8, 0x80000000 | (card << 11) | (bus << 16) | index)
			return PortIO.InShort(0xCFC)
		elif Type == 2:
			return PortIO.InShort(0xC000 | (card << 8) | index)
		else:
			return 0
	
	static def ReadLong(card as int, bus as int, index as int):
		if Type == 1:
			PortIO.OutLong(0xCF8, 0x80000000 | (card << 11) | (bus << 16) | index)
			return PortIO.InLong(0xCFC)
		elif Type == 2:
			return PortIO.InLong(0xC000 | (card << 8) | index)
		else:
			return 0
	
	static def WriteLong(card as int, bus as int, index as int, value as int):
		if Type == 1:
			PortIO.OutLong(0xCF8, 0x80000000 | (card << 11) | (bus << 16) | index)
			PortIO.OutLong(0xCFC, value)
		elif Type == 2:
			PortIO.OutLong(0xC000 | (card << 8) | index, value)
	
	def PrintDevice(num as uint):
		prints 'Vendor:'
		printhex num & 0xFFFF
		prints 'Device:'
		printhex num >> 16

