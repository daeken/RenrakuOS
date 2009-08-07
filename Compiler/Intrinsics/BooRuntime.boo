namespace Renraku.Compiler

class BooRuntimeIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Boo.Lang.Runtime::RuntimeServices')
		RegisterCall('NormalizeArrayIndex', NormalizeArrayIndex)
		RegisterCall('UnboxChar', UnboxChar)
	
	def NormalizeArrayIndex():
		yield ['swap']
		yield ['pop']
	
	def UnboxChar():
		yield ['nop']
