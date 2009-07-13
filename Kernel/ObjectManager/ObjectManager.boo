namespace Renraku.Kernel

import Renraku.Core.Memory

struct TypeDef:
	Size as uint

static class ObjectManager:
	def Init():
		print 'Object manager initialized.'
	
	def NewObj [of T](type as TypeDef) as T:
		return ObjPointer of T(MemoryManager.Allocate(type.Size)).Obj
