namespace Renraku.Kernel

import Renraku.Core.Memory

static class MemManager:
	def Init():
		print 'Memory manager initialized.'
	
	def Copy(destaddr as int, srcaddr as int, size as int):
		dest = Pointer of byte(destaddr)
		src = Pointer of byte(srcaddr)
		
		i = 0
		while i < size:
			dest[i] = src[i]
			++i
