namespace Renraku.Core.Memory

import System

class Pointer [of T]:
	def constructor(addr as int):
		pass
	
	def constructor(addr as uint):
		pass
	
	self[off as int] as T:
		get:
			raise Exception()
		set:
			pass
	
	self[off as uint] as T:
		get:
			raise Exception()
		set:
			pass
	
	Value as T:
		get:
			raise Exception()
		set:
			pass
	
	static def op_Addition(left as Pointer of T, right as int) as Pointer of T:
		return left
	
	static def GetAddr(obj as object) as uint:
		return 0

static class ObjPointer [of T]:
	def Get(addr as uint) as T:
		raise Exception()
