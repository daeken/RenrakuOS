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
		return cast(int, cast(IKeyboard, Hal.GetDriver(DriverClass.Keyboard)).Read())

	def ReadLine() as string:
		data as string = string(array(char,0))
		keyboard = cast(IKeyboard, Hal.GetDriver(DriverClass.Keyboard))
		while (key = keyboard.Read()) != char('\n'):
			if key != cast(char,0):
				if key == char('\b') and data.Length > 0:
					data = data.Substring(0, data.Length-1)
				else:
					ch = cast(char, key)
					WriteChar(ch)
					data = string.Concat((data, string((ch, ))))
		WriteChar(char('\n'))
		return data
	
	def Write(str as string):
		i = 0
		while i < str.Length:
			WriteChar(str[i++])
	
	def WriteChar(ch as char):
		CheckBounds()
		
		if ch == char('\n'):
			Position = 0
			Line++
		elif ch == char('\t'):
			Position += 8
		elif ch == char('\b'):
			if Position == 0:
				if Line > 0:
					Position = 79
					Line--
					WriteChar(char(' '))
					Position = 79
					Line--
			else:
				Position--
				WriteChar(char(' '))
				Position--
		else:
			vmem = Pointer of VChar(0xB8000 + Line*160 + Position*2)
			vmem.Value.Color = 7
			vmem.Value.Ch = cast(byte, ch)
			Position++
		
		CheckBounds()
	
	def WriteLine(str as string):
		i = 0
		while i < str.Length:
			WriteChar(str[i++])
		WriteChar(char('\n'))
	
	def WriteHex(num as uint):
		hexchars = '0123456789ABCDEF'
		for i in range(8):
			val = (num >> (28 - i*4)) & 0xF
			WriteChar(hexchars[val])
		WriteChar(char('\n'))
