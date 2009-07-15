namespace Renraku.Kernel

class Timer(IInterruptHandler):
	override Number:
		get:
			return 32
	
	def constructor():
		InterruptManager.Instance.AddHandler(self)
		
		print 'Timer initialized.'
	
	def Handle():
		print 'Timer interrupt fired.'
