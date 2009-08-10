namespace Renraku.Kernel

import Renraku.Core.Memory

struct TypeDef:
	Size as uint
	VTable as uint

static class ObjectManager:
	def Init():
		print 'Object manager initialized.'
	
	def NewArr(size as int, elemsize as int, vtable as int) as uint:
		addr = MemoryManager.Allocate(8 + size * elemsize)
		
		arr = Pointer of int(addr)
		arr[0] = vtable
		arr[1] = size
		
		return addr
	
	def NewDelegate(instance as uint, method as uint) as uint:
		addr = MemoryManager.Allocate(8)
		
		arr = Pointer of uint(addr)
		arr[0] = instance
		arr[1] = method
		
		return addr
	
	def NewObj(type as TypeDef) as uint:
		addr = MemoryManager.Allocate(4 + type.Size)
		
		obj = Pointer of uint(addr)
		obj.Value = type.VTable
		
		return addr
