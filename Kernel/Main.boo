namespace Renraku.Kernel

import System
import Renraku.Apps

static class Kernel:
	def Main():
		Console.Init()
		MemoryManager.Init()
		ObjectManager.Init()
		InterruptManager.Disable()
		InterruptManager()
		Hal()
		Drivers.Load()
		InterruptManager.Enable()
		
		print 'Renraku initialized.'
		
		print 'Launching default app...'
		Shell().Run(null)
	
	def Fault():
		print 'Fault.'
		
		while true:
			pass
