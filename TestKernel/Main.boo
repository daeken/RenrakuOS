namespace Renraku.TestKernel

import Renraku.Core.Memory

def ClearScreen():
	vmem = Pointer of ushort(0xB8000)
	for i in range(89600):
		vmem[i*2] = 0

def SetChar(x as int, y as int, ch as char):
	vmem = Pointer of ushort(0xB8000)
	vmem[(x+(y*320))*2] = cast(ushort, 0x0F00 | cast(int, ch))

def Main():
	ClearScreen()
	
	chars = 'Hello world!'
	for i in range(12):
		SetChar(i, 0, chars[i])
