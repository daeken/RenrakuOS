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
