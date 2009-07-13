namespace Renraku.Kernel

static class Kernel:
	def Main():
		Console.Init()
		MemoryManager.Init()
		ObjectManager.Init()
		InterruptManager()
		
		print 'Renraku initialized.'
