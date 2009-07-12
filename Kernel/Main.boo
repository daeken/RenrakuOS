namespace Renraku.Kernel

static class Kernel:
	def Main():
		Console.Init()
		MemManager.Init()
		ObjManager.Init()
		
		print 'Renraku initialized.'
