namespace Renraku.Compiler

class ObjectIntrinsics(ClassIntrinsic):
	def constructor():
		Register('System::Object')
		RegisterCall('.ctor', Ctor)
	
	def Ctor() as duck:
		yield ['pop']
