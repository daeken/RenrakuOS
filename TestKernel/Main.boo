namespace Renraku.TestKernel

import Renraku.Core.Memory

struct VChar:
	Ch as byte
	Color as byte

static class TestKernel:
	def Memcpy(destaddr as int, srcaddr as int, size as int):
		dest = Pointer of byte(destaddr)
		src = Pointer of byte(srcaddr)
		
		i = 0
		while i < size:
			dest[i] = src[i]
			++i
	
	def ClearScreen():
		vmem = Pointer of VChar(0xB8000)
		for i in range(2000): # 80x25
			vmem.Value.Color = 0
			vmem += 1
	
	Position = 0
	def Print(str as string):
		if Position == 25:
			Position = 24
			Memcpy(0xB8000, 0xB8000+160, 80*24*2)
		
		vmem = Pointer of VChar(0xB8000 + Position*160)
		i = 0
		while str[i] != char(0):
			vmem.Value.Color = 0x0F
			vmem.Value.Ch = cast(byte, str[i])
			i++
			vmem += 1
		Position++
	
	def Main():
		ClearScreen()
		Print('Hello World!')
		Print('Hello from Renraku!')
		Print('Hello from Renraku part two.')
		Print('Now this is how a managed kernel is done.')
		for i in range(21):
			Print('...')
		for i in range(100000000): # Holy primitive waitloop, batman!
			i *= 2
		Print('Hello World should now be gone.')
