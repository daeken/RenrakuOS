namespace Renraku.Kernel

class Keyboard(IInterruptHandler):
	override Number:
		get:
			return 33
	
	public static Instance as Keyboard
	
	def constructor():
		Instance = self
		InterruptManager.Instance.AddHandler(self)
		
		print 'Keyboard initialized.'
	
	def Handle():
		scancode = PortIO.InByte(0x60)
		if scancode & 0x80 == 0:
			print 'Key down:'
		else:
			print 'Key up:'
			scancode &= 0x7F
		printhex scancode
