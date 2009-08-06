namespace Renraku.Kernel

import Renraku.Core.Memory

public interface IMouseProvider:
	pass

public class MouseService(IInterruptHandler, IMouseProvider, IService):
	override ServiceId:
		get:
			return 'mouse'
	
	override InterruptNumber:
		get:
			return 44
	
	Buffer as (byte)
	Cycle as int
	
	def constructor():
		Buffer = array(byte, 3)
		Cycle = 0
		
		WaitSignal()
		PortIO.OutByte(0x64, 0xA8) # Mouse enable
		
		WaitSignal()
		PortIO.OutByte(0x64, 0x20) # Get Compaq status byte
		status = Read()
		WaitSignal()
		PortIO.OutByte(0x64, 0x60) # Set Compaq status byte
		WaitSignal()
		PortIO.OutByte(0x60, status | 2)
		
		Write(0xF6) # Use default settings
		Read()
		
		Write(0xF4) # Enable movement packets
		Read()
		
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
	
	def Read() as byte:
		WaitData()
		return PortIO.InByte(0x60)
	
	def Handle(_ as Pointer [of uint]):
		Buffer[Cycle++] = PortIO.InByte(0x60)
		
		if Cycle == 3:
			Cycle = 0
