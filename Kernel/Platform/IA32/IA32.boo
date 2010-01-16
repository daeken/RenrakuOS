namespace Renraku.Kernel

import System

static class Platform:
	def Init():
		Console.Init()
		MemoryManager.Init()
		ObjectManager.Init()
		
		Context.CurrentContext = Context()
		
		InterruptManager.Disable()
		InterruptManager()
		
		InterruptManager.Enable()
