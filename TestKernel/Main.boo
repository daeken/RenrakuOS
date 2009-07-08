namespace Renraku.TestKernel

import Renraku.Core.Memory

static class TestKernel:
	def ClearScreen():
		vmem = Pointer of ushort(0xB8000)
		for i in range(89600):
			vmem[i*2] = 0
	
	Position = 0
	def Print(size as int, str as string):
		vmem = Pointer of ushort(0xB8000)
		if Position == 25:
			Position = 24
			for y in range(24):
				y *= 160
				for x in range(160):
					vmem[y+x] = vmem[y+x+80]
		
		i = 0
		while i < size:
			vmem[(Position*80+i)*2] = cast(ushort, 0x0F00 | cast(int, str[i]))
			i++
		Position++
	
	def Main():
		ClearScreen()
		Print(19, 'Hello from Renraku!')
		Print(28, 'Hello from Renraku part two.')
