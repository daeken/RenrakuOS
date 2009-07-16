namespace Renraku.Kernel

class PciDevice:
	virtual Vendor as int:
		get:
			return 0xFFFF
	
	virtual DeviceId as int:
		get:
			return 0xFFFF
	
	virtual Bus as int:
		get:
			return 0
		set:
			pass
	
	virtual Card as int:
		get:
			return 0
		set:
			pass
	
	def Find():
		if Pci.Type == 1:
			for bus in range(16):
				for card in range(32):
					tmp = Pci.ReadLong(card, bus, 0)
					if Vendor == (tmp & 0xFFFF) and DeviceId == (tmp >> 16):
						Bus = bus
						Card = card
						return true
		elif Pci.Type == 2:
			PortIO.OutShort(0xCF8, 0x80)
			PortIO.OutShort(0xCFA, 0)
			for card in range(16):
				tmp = Pci.ReadLong(card, 0, 0)
				if Vendor == (tmp & 0xFFFF) and DeviceId == (tmp >> 16):
					Bus = 0
					Card = card
					return true
		
		return false

class Pci:
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
	
	def PrintDevice(num as uint):
		prints 'Vendor:'
		printhex num & 0xFFFF
		prints 'Device:'
		printhex num >> 16

