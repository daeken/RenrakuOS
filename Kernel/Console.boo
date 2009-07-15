namespace Renraku.Kernel

import Renraku.Core.Memory

struct VChar:
	Ch as byte
	Color as byte

static class Console:
	def Init():
		self.ClearScreen()
		print 'Console initialized.'
	
	def ClearScreen():
		vmem = Pointer of VChar(0xB8000)
		for i in range(2000): # 80x25
			vmem.Value.Color = 0
			vmem += 1
	
	Position = 0
	def PrintLine(str as string):
		if Position == 25:
			Position = 24
			MemoryManager.Copy(0xB8000, 0xB8000+160, 80*24*2)
		
		vmem = Pointer of VChar(0xB8000 + Position*160)
		i = 0
		while str[i] != char(0):
			vmem.Value.Color = 0x0F
			vmem.Value.Ch = cast(byte, str[i])
			i++
			vmem += 1
		Position++
	
	def PrintHex(num as uint):
		if Position == 25:
			Position = 24
			MemoryManager.Copy(0xB8000, 0xB8000+160, 80*24*2)
		
		hexchars = '0123456789ABCDEF'
		vmem = Pointer of VChar(0xB8000 + Position*160)
		for i in range(8):
			val = (num >> (28 - i*4)) & 0xF
			vmem.Value.Color = 0x0F
			vmem.Value.Ch = cast(byte, hexchars[val])
			vmem += 1
		Position++
