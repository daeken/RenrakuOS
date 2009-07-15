namespace Renraku.Kernel

class Keyboard(IInterruptHandler):
	override Number:
		get:
			return 33
	
	def constructor():
		InterruptManager.Instance.AddHandler(self)
		
		print 'Keyboard initialized.'
	
	def Handle():
		print 'Keyboard interrupt fired.'
		PortIO.InByte(0x60)
