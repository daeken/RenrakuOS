namespace Renraku.Kernel

import Renraku.Core.Memory

struct IdtEntry:
	BaseLow as ushort
	Selector as ushort
	Empty as byte
	Flags as byte
	BaseHigh as ushort

struct IdtPointer:
	Limit as ushort
	Base as uint

interface IInterruptHandler:
	Number as int:
		get:
			pass
	
	def Handle() as void:
		pass

class InterruptManager:
	public static Instance as InterruptManager = null
	Isrs as (IInterruptHandler)
	
	def constructor():
		Instance = self
		
		idtaddr = MemoryManager.Allocate(48 * 8)
		idtp = Pointer of IdtPointer(MemoryManager.Allocate(6))
		idtp.Value.Limit = 8*48-1
		idtp.Value.Base = idtaddr
		BuildInterruptBoilerplates idtaddr # Macros ahoy!
		Load(idtp)
		
		Isrs = array(IInterruptHandler, 48)
		
		RemapIrqs()
		Enable()
		
		print 'Interrupt manager initialized.'
	
	def RemapIrqs():
		PortIO.OutByte(0x20, 0x11)
		PortIO.OutByte(0xA0, 0x11)
		PortIO.OutByte(0x21, 0x20)
		PortIO.OutByte(0xA1, 0x28)
		PortIO.OutByte(0x21, 0x04)
		PortIO.OutByte(0xA1, 0x02)
		PortIO.OutByte(0x21, 0x01)
		PortIO.OutByte(0xA1, 0x01)
		PortIO.OutByte(0x21, 0x0)
		PortIO.OutByte(0xA1, 0x0)
	
	def AddHandler(handler as IInterruptHandler):
		print 'Adding ISR number:'
		printhex handler.Number
		Isrs[handler.Number] = handler
	
	def Handle(num as int) as int:
		if Isrs[num] == null:
			print 'Unhandled interrupt:'
			printhex num
		else:
			Isrs[num].Handle()
		
		if num >= 32: # Send EOI to PICs
			if num >= 40:
				PortIO.OutByte(0xA0, 0x20)
			PortIO.OutByte(0x20, 0x20)
		
		if num == 8 or (num >= 10 and num <= 14):
			return 1
		else:
			return 0
	
	static def Load(idt as Pointer [of IdtPointer]):
		pass # Intrinsic away!
	
	static def BuildIsrStub(idt as uint, num as int):
		pass
	
	static def Enable():
		pass # Intrinsic away!
