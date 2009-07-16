namespace Renraku.Kernel

interface IKeymap:
	def Map(scancode as int) as int:
		pass

class Keyboard(IKeyboard, IInterruptHandler):
	override Class:
		get:
			return DriverClass.Keyboard
	
	override Number:
		get:
			return 33
	
	public static Instance as Keyboard
	
	Waiting as bool
	Ready as bool
	Ch as int
	
	public Keymap as IKeymap
	
	def constructor():
		Instance = self
		Waiting = false
		Ready = false
		Keymap = null
		InterruptManager.AddHandler(self)
		Hal.Register(self)
		
		print 'Keyboard initialized.'
	
	def Handle():
		if not Waiting or Ready:
			PortIO.InByte(0x60) # Drop key
		
		scancode = PortIO.InByte(0x60)
		if scancode & 0x80 == 0: # Key down
			pass
		else:
			scancode &= 0x7F
			Ch = scancode
			Ready = true
	
	def PrintStatus():
		print 'Keyboard: OK'
	
	def Read() as char:
		Ready = false
		Waiting = true
		
		while not Ready:
			pass
		Waiting = false
		
		if Keymap == null:
			return cast(char, Ch)
		else:
			return cast(char, Keymap.Map(Ch))
