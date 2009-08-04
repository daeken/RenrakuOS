namespace Renraku.Kernel

import System.Collections

interface IKeymap:
	def Map(scancode as int) as int:
		pass

interface IKeyboardProvider:
	def Read() as char:
		pass
	
	def HasData() as bool:
		pass

class KeyboardService(IInterruptHandler, IKeyboardProvider, IService):
	override ServiceId:
		get:
			return 'keyboard'
	
	override InterruptNumber:
		get:
			return 33
	
	private Buffer as Queue

	static final DATA_PORT = 0x60
	static final COMMAND_PORT = 0x64
	
	public Keymap as IKeymap
	
	def constructor():
		Buffer = Queue()
		cmd_byte = ReadCmdByte()
		InterruptManager.AddHandler(self)
		Context.Register(self)
		
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

	def ReportScancode(scancode as byte) as char:
		key = cast(char, 0)
		# Ignore release codes
		if scancode & 0x80 == 0:
			if Keymap == null:
				key = cast(char, scancode)
			else:
				key = cast(char, Keymap.Map(scancode))
			Buffer.Enqueue(key)

	def Handle():
		scancode = ReadData()
		ReportScancode(scancode)

	public def Read() as char:
		# Block waiting for input
		while not HasData():
			pass
		
		# We don't want any interrupts ruining our fun
		InterruptManager.Disable()
		ch = Buffer.Dequeue()
		InterruptManager.Enable()
		return ch
	
	public def HasData() as bool:
		return Buffer.Length != 0
