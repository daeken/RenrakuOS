namespace Renraku.TestKernel

import Renraku.Core.Memory

def Main():
	vmem = Pointer of ushort(0xB8000)
	color = cast(ushort, 0x0F << 8)
	vmem[ 0] = color | cast(ushort, char('H'))
	vmem[ 1] = color | cast(ushort, char('e'))
	vmem[ 2] = color | cast(ushort, char('l'))
	vmem[ 3] = color | cast(ushort, char('l'))
	vmem[ 4] = color | cast(ushort, char('o'))
	vmem[ 5] = color | cast(ushort, char(' '))
	vmem[ 6] = color | cast(ushort, char('W'))
	vmem[ 7] = color | cast(ushort, char('o'))
	vmem[ 8] = color | cast(ushort, char('r'))
	vmem[ 9] = color | cast(ushort, char('l'))
	vmem[10] = color | cast(ushort, char('d'))
	vmem[11] = color | cast(ushort, char('!'))
