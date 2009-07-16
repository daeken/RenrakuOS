namespace Renraku.Kernel

class Timer(ITimer, IInterruptHandler):
	override Class:
		get:
			return DriverClass.Timer
	
	override Number:
		get:
			return 32
	
	def constructor():
		InterruptManager.AddHandler(self)
		Hal.Register(self)
		
		print 'Timer initialized.'
	
	def Handle():
		pass
	
	def PrintStatus():
		print 'Timer: OK'
