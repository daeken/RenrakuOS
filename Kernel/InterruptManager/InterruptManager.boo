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
	
	def Handle():
		pass

class InterruptManager:
	static Instance as InterruptManager = null
	Idt as Pointer of IdtEntry
	
	Isrs as (IInterruptHandler)
	
	def constructor():
		Instance = self
		
		idtaddr = MemoryManager.Allocate(256 * 8)
		Idt = Pointer of IdtEntry(idtaddr)
		idtp = Pointer of IdtPointer(MemoryManager.Allocate(6))
		idtp.Value.Limit = 8*256-1
		idtp.Value.Base = idtaddr
		Load(idtp)
		
		Isrs = array(IInterruptHandler, 256)
		
		print 'Interrupt manager initialized.'
	
	def AddHandler(handler as IInterruptHandler):
		Isrs[0] = handler
	
	static def Load(idt as Pointer [of IdtPointer]):
		pass # Intrinsic away!
