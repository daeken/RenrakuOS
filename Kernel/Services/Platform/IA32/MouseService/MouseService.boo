namespace Renraku.Kernel

import System.Collections
import Renraku.Core.Memory

public interface IMouseProvider:
	def Read() as MouseEvent:
		pass

public enum MouseEventType:
	Movement
	ButtonDown
	ButtonUp

public class MouseEvent:
	public Type as MouseEventType
	public Button as int
	public Delta as (int)
	
	def constructor(type as MouseEventType):
		Type = type
		Button = -1
		Delta = null

public class MouseService(IInterruptHandler, IMouseProvider, IService):
	override ServiceId:
		get:
			return 'mouse'
	
	override InterruptNumber:
		get:
			return 44
	
	Buffer as (byte)
	Cycle as int
	Eat as int
	
	EventQueue as Queue
	ButtonState as int
	
	def constructor():
		Buffer = array(byte, 3)
		Cycle = -1
		
		EventQueue = Queue()
		ButtonState = 0
		
		WaitSignal()
		PortIO.OutByte(0x64, 0xA8) # Mouse enable
		
		WaitSignal()
		PortIO.OutByte(0x64, 0x20) # Get Compaq status byte
		status = ReadData()
		WaitSignal()
		PortIO.OutByte(0x64, 0x60) # Set Compaq status byte
		WaitSignal()
		PortIO.OutByte(0x60, status | 2)
		
		Write(0xF6) # Use default settings
		ReadData()
		
		Write(0xF4) # Enable movement packets
		ReadData()
		
		InterruptManager.AddHandler(self)
		Context.Register(self)
		
		print 'Mouse initialized.'
	
	def WaitData():
		while PortIO.InByte(0x64) & 1 == 0:
			pass
	
	def WaitSignal():
		while PortIO.InByte(0x64) & 2 != 0:
			pass
	
	def Write(cmd as byte):
		WaitSignal()
		PortIO.OutByte(0x64, 0xD4)
		WaitSignal()
		PortIO.OutByte(0x60, cmd)
	
	def ReadData() as byte:
		WaitData()
		return PortIO.InByte(0x60)
	
	def Handle(_ as Pointer [of uint]):
		if Cycle == -1:
			PortIO.InByte(0x60)
			Cycle = 0
			return
		
		Buffer[Cycle++] = PortIO.InByte(0x60)
		
		if Cycle == 3:
			Cycle = 0
			
			if Buffer[0] & 0xC0 != 0:
				return
			
			SendButtonEvent(Buffer[0], 2)
			SendButtonEvent(Buffer[0], 1)
			SendButtonEvent(Buffer[0], 0)
			ButtonState = Buffer[0] & 0x7
			
			if Buffer[1] != 0 or Buffer[2] != 0:
				evt = MouseEvent(MouseEventType.Movement)
				Delta = array(int, 2)
				Delta[0] = Buffer[1]
				Delta[1] = Buffer[2]
				if Buffer[0] & 0x10 != 0:
					Delta[0] -= 256
				if Buffer[0] & 0x20 != 0:
					Delta[1] -= 256
				evt.Delta = Delta
				EventQueue.Enqueue(evt)
	
	def SendButtonEvent(buffer as int, off as int):
		current = (buffer >> off) & 1
		old = (ButtonState >> off) & 1
		
		if current != old:
			if current == 1:
				evt = MouseEvent(MouseEventType.ButtonDown)
			else:
				evt = MouseEvent(MouseEventType.ButtonUp)
			
			evt.Button = off + 1
			EventQueue.Enqueue(evt)
	
	def Read() as MouseEvent:
		if EventQueue.Count == 0:
			return null
		
		InterruptManager.Disable()
		evt = EventQueue.Dequeue()
		InterruptManager.Enable()
		return evt
