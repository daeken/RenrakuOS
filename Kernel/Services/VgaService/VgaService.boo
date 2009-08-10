namespace Renraku.Kernel

import Renraku.Core.Memory

public interface IVideoProvider:
	Graphical as bool:
		get:
			pass
		set:
			pass
	
	Resolution as (int):
		get:
			pass
	
	def Clear():
		pass
	
	def SwapBuffers():
		pass
	
	def SetPalette(i as byte, r as byte, g as byte, b as byte):
		pass
	
	def SetPixel(x as int, y as int, color as byte):
		pass
	
	def Fill(x as int, y as int, w as int, h as int, color as byte):
		pass

public class VgaService(IService, IVideoProvider):
	override ServiceId:
		get:
			return 'video'
	
	_Graphical as bool
	Graphical:
		get:
			return _Graphical
		set:
			if value:
				MemoryManager.Copy(Pointer [of byte].GetAddr(BackupTextBuffer), 0xB8000, 4000) # Back up text buffer
				SetMode((
						# MISC reg,  STATUS reg,    SEQ regs
						0x63,        0x00,          0x03,0x01,0x0F,0x00,0x0E,
						# CRTC regs
						0x5F,0x4F,0x50,0x82,0x54,0x80,0xBF,0x1F,0x00,0x41,0x00,0x00,
						0x00,0x00,0x00,0x00,0x9C,0x0E,0x8F,0x28,0x40,0x96,0xB9,0xA3,
						0xFF,
						# GRAPHICS regs
						0x00,0x00,0x00,0x00,0x00,0x40,0x05,0x0F,0xFF,
						# ATTRIBUTE CONTROLLER regs
						0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,
						0x0C,0x0D,0x0E,0x0F,0x41,0x00,0x0F,0x00,0x00
					))
				_Graphical = true
			else:
				SetMode((
						# MISC reg,  STATUS reg,    SEQ regs
						0x67,        0x00,          0x03,0x00,0x03,0x00,0x02,
						# CRTC regs
						0x5F,0x4F,0x50,0x82,0x55,0x81,0xBF,0x1F,0x00,0x4F,0x0E,0x0F,
						0x00,0x00,0x00,0x00,0x9C,0x0E,0x8F,0x28,0x01,0x96,0xB9,0xA3,
						0xFF,
						# GRAPHICS regs
						0x00,0x00,0x00,0x00,0x00,0x10,0x0E,0x00,0xFF,
						# ATTRIBUTE CONTROLLER regs
						0x00,0x01,0x02,0x03,0x04,0x05,0x14,0x07,0x10,0x11,0x3A,0x3B,
						0x3C,0x3D,0x3E,0x3F,0x0C,0x00,0x0F,0x08,0x00
					))
				MemoryManager.Copy(0xB8000, Pointer [of byte].GetAddr(BackupTextBuffer), 4000) # Copy in backup text buffer
				_Graphical = false
	
	Resolution:
		get:
			return (320, 200)
	
	BackupTextBuffer as (byte)
	BackBuffer as (byte)
	def constructor():
		_Graphical = false
		BackupTextBuffer = array(byte, 4000)
		BackBuffer = array(byte, 320*200)
		
		Context.Register(self)
		print 'VGA initialized.'
	
	def SetMode(modeRegs as (int)):
		ClearVRam()
		
		PortIO.OutByte(0x3C2, modeRegs[0])
		PortIO.OutByte(0x3DA, modeRegs[1])
		
		for i in range(5):
			PortIO.OutByte(0x3C4, i)
			PortIO.OutByte(0x3C5, modeRegs[2+i])
		
		PortIO.OutShort(0x3D4, 0x0E11)
		
		for i in range(25):
			PortIO.OutByte(0x3D4, i)
			PortIO.OutByte(0x3D5, modeRegs[7+i])
		
		for i in range(9):
			PortIO.OutByte(0x3CE, i)
			PortIO.OutByte(0x3CF, modeRegs[32+i])
		
		PortIO.InByte(0x3DA)
		for i in range(21):
			PortIO.InShort(0x3C0)
			PortIO.OutByte(0x3C0, i)
			PortIO.OutByte(0x3C0, modeRegs[41+i])
		
		PortIO.OutByte(0x3C0, 0x20)
		
		Clear()
		SwapBuffers()
	
	def Clear():
		for i in range(64000):
			BackBuffer[i] = 0
	
	def ClearVRam():
		MemoryManager.Zero(0xA0000, 320*200)
		MemoryManager.Zero(0xB8000, 4000)
	
	def SwapBuffers():
		while (PortIO.InByte(0x3DA) & 0x08) != 0:
			pass
		while (PortIO.InByte(0x3DA) & 0x08) == 0:
			pass
		
		i = 0
		mem = Pointer [of byte](0xA0000)
		while i < 320*200:
			mem.Value = BackBuffer[i++]
			mem += 1
	
	def SetPalette(i as byte, r as byte, g as byte, b as byte):
		PortIO.OutByte(0x3C6, 0xFF)
		PortIO.OutByte(0x3C8, i)
		PortIO.OutByte(0x3C9, r >> 2)
		PortIO.OutByte(0x3C9, g >> 2)
		PortIO.OutByte(0x3C9, b >> 2)
	
	def SetPixel(x as int, y as int, color as byte):
		BackBuffer[y*320 + x] = color
	
	def Fill(x as int, y as int, w as int, h as int, color as byte):
		th = h
		ty = y
		while th-- > 0:
			base = ty*320 + x
			tw = w
			while tw-- > 0:
				BackBuffer[base++] = color
			ty++
