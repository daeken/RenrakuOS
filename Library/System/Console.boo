namespace System

import Renraku.Core.Memory
import Renraku.Kernel

struct VChar:
	Ch as byte
	Color as byte

static class Console:
	Position = 0
	Line = 0
	
	def Init():
		self.Clear()
		print 'Console initialized.'
	
	def CheckBounds():
		if Position >= 80:
			Position = 0
			Line++
		
		if Line >= 25:
			MoveUp()
	
	def Clear():
		vmem = Pointer of VChar(0xB8000)
		for i in range(2000): # 80x25
			vmem.Value.Color = 0
			vmem += 1
	
	def MoveUp():
		MemoryManager.Copy(0xB8000, 0xB8000+160, 80*24*2)
		MemoryManager.Zero(0xB8000 + 24*160, 160)
		Line = 24
		Position = 0
	
	def Read() as int:
		return Keyboard.Instance.Read()
	
	def WriteChar(ch as char):
		CheckBounds()
		
		if ch == char('\n'):
			Position = 0
			Line++
		elif ch == char('\t'):
			Position += 8
		else:
			vmem = Pointer of VChar(0xB8000 + Line*160 + Position*2)
			vmem.Value.Color = 7
			vmem.Value.Ch = cast(byte, ch)
			Position++
		
		CheckBounds()
	
	def WriteLine(str as string):
		i = 0
		while str[i] != char(0):
			WriteChar(str[i++])
		WriteChar(char('\n'))
	
	def WriteHex(num as uint):
		hexchars = '0123456789ABCDEF'
		for i in range(8):
			val = (num >> (28 - i*4)) & 0xF
			WriteChar(hexchars[val])
		WriteChar(char('\n'))
