namespace Renraku.TestKernel

import Renraku.Core.Memory

static class TestKernel:
	def ClearScreen():
		vmem = Pointer of ushort(0xB8000)
		for i in range(89600):
			vmem[i*2] = 0
	
	Position = 0
	def Print(str as string):
		vmem = Pointer of ushort(0xB8000)
		if Position == 25:
			Position = 24
			for y in range(24):
				y *= 160
				for x in range(160):
					vmem[y+x] = vmem[y+x+160]
		
		i = 0
		while str[i] != char(0):
			vmem[(Position*80+i)*2] = cast(ushort, 0x0F00 | cast(int, str[i]))
			i++
		Position++
	
	def Main():
		ClearScreen()
		Print('Hello World!')
		Print('Hello from Renraku!')
		Print('Hello from Renraku part two.')
		Print('Now this is how a managed kernel is done.')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		Print('...')
		for i in range(100000000): # Holy primitive waitloop, batman!
			i *= 2
		Print('Hello World should now be gone.')
