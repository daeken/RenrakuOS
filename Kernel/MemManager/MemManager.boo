namespace Renraku.Kernel

import Renraku.Core.Memory

static class MemManager:
	CurAddr as uint
	
	def Init():
		CurAddr = 0x00800000 # Start allocating at 8MB, above the stack
		
		print 'Memory manager initialized.'
	
	def Copy(destaddr as int, srcaddr as int, size as int):
		dest = Pointer of byte(destaddr)
		src = Pointer of byte(srcaddr)
		
		i = 0
		while i < size:
			dest[i] = src[i]
			++i
	
	def Allocate(size as uint) as uint:
		addr = CurAddr
		CurAddr += size
		return addr
