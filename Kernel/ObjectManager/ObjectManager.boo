namespace Renraku.Kernel

import Renraku.Core.Memory

struct TypeDef:
	Size as uint
	VTable as uint

static class ObjectManager:
	def Init():
		print 'Object manager initialized.'
	
	def NewArr(size as int, elemsize as int) as uint:
		return MemoryManager.Allocate(size * elemsize)
	
	def NewObj(type as TypeDef) as uint:
		addr = MemoryManager.Allocate(4+type.Size)
		
		obj = Pointer of uint(addr)
		obj.Value = type.VTable
		
		return addr
