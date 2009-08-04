namespace Renraku.Kernel

class TimerService(IInterruptHandler, IService):
	override ServiceId:
		get:
			return 'timer'
	
	override InterruptNumber:
		get:
			return 32
	
	def constructor():
		InterruptManager.AddHandler(self)
		Context.Register(self)
		
		print 'Timer initialized.'
	
	def Handle():
		pass
