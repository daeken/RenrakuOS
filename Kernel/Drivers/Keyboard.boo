namespace Renraku.Kernel

class KeyboardIsr(IInterruptHandler):
	override Number:
		get:
			return 1
	
	def Handle():
		print 'Keyboard interrupt fired.'

class Keyboard:
	Instance as Keyboard
	
	def constructor():
		Instance = self
		
		InterruptManager.Instance.AddHandler(KeyboardIsr())
		
		print 'Keyboard initialized.'
