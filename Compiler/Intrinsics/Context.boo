namespace Renraku.Compiler

class ContextIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Renraku.Kernel::Context')
		RegisterCall('get_CurrentContext', GetCurrentContext)
		RegisterCall('set_CurrentContext', SetCurrentContext)
	
	def GetCurrentContext() as duck:
		yield ['pushcontext']
	
	def SetCurrentContext() as duck:
		yield ['popcontext']
