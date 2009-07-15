namespace Renraku.Kernel

interface IKeymap:
	def Map(scancode as int) as int:
		pass

class Keyboard(IInterruptHandler):
	override Number:
		get:
			return 33
	
	public static Instance as Keyboard
	
	Waiting as bool
	Ready as bool
	Ch as int

	DATA_PORT = 0x60
	COMMAND_PORT = 0x64
	
	public Keymap as IKeymap
	
	def constructor():
		Instance = self
		Waiting = false
		Ready = false
		Keymap = null

		cmd_byte = ReadCmdByte()
		InterruptManager.Instance.AddHandler(self)
		print 'Keyboard initialized.'
		if cmd_byte & 0x40:
			print "Running in translate mode."
		else:
			print "No translate mode."
	
	def ReadStatus() as byte:
		return PortIO.InByte(COMMAND_PORT)

	def WriteCmdByte(cmd as byte):
		PortIO.OutByte(COMMAND_PORT, cmd)

	def ReadData() as byte:
		return PortIO.InByte(DATA_PORT)

	def ReadCmdByte() as byte:
		while (ReadStatus() & 0x2) == 1:
			pass
		WriteCmdByte(0x20)

		# Wait until data is ready
		while (ReadStatus() & 0x1) == 0:
			pass

		return ReadData()

	def Handle():
		if not Waiting or Ready:
			ReadData() # Drop key
		
		scancode = ReadData()
		if scancode & 0x80 == 0: # Key down
			pass
		else:
			scancode &= 0x7F
			Ch = scancode
			Ready = true
	
	def Read() as int:
		Ready = false
		Waiting = true
		
		while not Ready:
			pass
		Waiting = false
		
		if Keymap == null:
			return Ch
		else:
			return Keymap.Map(Ch)
