namespace Renraku.Compiler

class BooRuntimeIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Boo.Lang.Runtime::RuntimeServices')
		RegisterCall('NormalizeArrayIndex', NormalizeArrayIndex)
	
	def NormalizeArrayIndex():
		yield ['swap']
		yield ['pop']
