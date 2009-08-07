namespace Renraku.Apps

import Renraku.Core.Memory
import Renraku.Kernel

class Logo(Application):
	override Name as string:
		get:
			return 'logo'
	
	Pixels as Pointer [of byte]:
		get:
			return Pointer [of byte](0) # Intrinsic away!
	
	Palette as Pointer [of byte]:
		get:
			return Pointer [of byte](0) # Intrinsic away!
	
	def Run(_ as (string)):
		keyboard = cast(IKeyboardProvider, Context.Service['keyboard'])
		video = cast(IVideoProvider, Context.Service['video'])
		
		video.Graphical = true
		
		video.Clear()
		
		buf = Palette
		off = 0
		for i in range(256):
			video.SetPalette(i, buf[off], buf[off+1], buf[off+2])
			off += 3
		
		x = 0
		y = 0
		pixelBuf = Pixels
		for i in range(36480):
			video.SetPixel(x, y, pixelBuf.Value)
			pixelBuf += 1
			
			if ++y == 114:
				y = 0
				++x
		video.SwapBuffers()
		
		while keyboard.Read() != char(' '):
			pass
		
		video.Graphical = false
