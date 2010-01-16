namespace Renraku.Kernel

import System.Collections
import Renraku.Core.Memory

interface IKeymap:
	def Map(scancode as int, shiftlevel as int) as int:
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
	private shift as int

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

	def HandleScancode(scancode as byte):
		pressed = (~scancode & 0x80)
		key = scancode & 0x7F

		if key == 0x2A or key == 0x36:
			is_shift = true
		else:
			is_shift = false

		if pressed:
			if is_shift:
				++shift
			else:
				ReportKey(key)
		else:
			if shift and is_shift:
				--shift

	def ReportKey(key as byte):
		real_key = cast(char, 0)
		if Keymap == null:
			real_key = cast(char, key)
		else:
			if shift:
				shiftlevel = 1
			else:
				shiftlevel = 0
			real_key = cast(char, Keymap.Map(key, shiftlevel))
		Buffer.Enqueue(real_key)

	def Handle(_ as Pointer [of uint]):
		scancode = ReadData()
		HandleScancode(scancode)

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
		return Buffer.Count != 0
