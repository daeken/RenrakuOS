namespace Renraku.Apps

import System
import Renraku.Kernel

class Pci:
	def Scan():
		PortIO.OutShort(0xCF8, 0)
		PortIO.OutShort(0xCFA, 0)
		
		if PortIO.InShort(0xCF8) == 0 and PortIO.InShort(0xCFA) == 0:
			type = 2
		else:
			tmp = PortIO.InLong(0xCF8)
			PortIO.OutLong(0xCF8, 0x80000000)
			if PortIO.InLong(0xCF8) == 0x80000000:
				type = 1
			PortIO.OutLong(0xCF8, tmp)
		
		if type == 1:
			print 'PCI type 1'
			for i in range(512):
				PortIO.OutLong(0xCF8, 0x80000000 + i * 2048)
				tmp = PortIO.InLong(0xCFC)
				if (tmp & 0xFFFF) != 0xFFFF and (tmp >> 16) != 0xFFFF:
					PrintDevice(tmp)
		elif type == 1:
			print 'PCI type 2'
			PortIO.OutShort(0xCF8, 0x80)
			PortIO.OutShort(0xCFA, 0)
			for i in range(16):
				tmp = PortIO.InLong(i*256 + 0xC000)
				if (tmp & 0xFFFF) != 0xFFFF and (tmp >> 16) != 0xFFFF:
					PrintDevice(tmp)
		else:
			print 'No PCI?'
	
	def PrintDevice(num as uint):
		print 'PCI Device!  Vendor:'
		printhex num & 0xFFFF
		print 'Device:'
		printhex num >> 16

class PciDump(Application):
	override Name as string:
		get:
			return 'pci'
	
	def Run(_ as (string)):
		pci = Pci()
		pci.Scan()
