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

class InterruptManager:
	static Instance as InterruptManager = null
	Idt as Pointer of IdtEntry
	
	def constructor():
		Instance = self
		
		Install()
		
		print 'Interrupt manager initialized.'
	
	def Install():
		idtaddr = MemoryManager.Allocate(256 * 8)
		Idt = Pointer of IdtEntry(idtaddr)
		idtp = Pointer of IdtPointer(MemoryManager.Allocate(6))
		idtp.Value.Limit = 8*256-1
		idtp.Value.Base = idtaddr
		Load(idtp)
	
	static def Load(idt as Pointer [of IdtPointer]):
		pass # Intrinsic away!
