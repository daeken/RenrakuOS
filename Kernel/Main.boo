namespace Renraku.Kernel

import System
#import Renraku.Apps

static class Kernel:
	def Main():
		Platform.Init()
		Services.Register()
		
		print 'Renraku initialized.'
		
		print 'Launching default app...'
		#Shell().Run(null)
	
	def Fault():
		print 'Fault.'
		
		while true:
			pass

# XXX: Needed for hosted mode
Kernel.Main()
