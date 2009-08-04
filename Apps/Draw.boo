namespace Renraku.Apps

import Renraku.Kernel

class Draw(Application):
	override Name as string:
		get:
			return 'draw'
	
	def Run(_ as (string)):
		keyboard = cast(IKeyboardProvider, Context.Service['keyboard'])
		video = cast(IVideoProvider, Context.Service['video'])
		
		video.Graphical = true
		
		
		#x = 0
		#y = 0
		#w = 20
		#h = 20
		#revX = false
		#revY = false
		color = 0
		while not keyboard.HasData():
			video.WaitForRefresh()
			for x in range(320):
				for y in range(200):
					video.SetPixel(x, y, color)
					color = (color+1) & 0xFF
		#	video.Clear()
		#	video.Fill(x, y, w, h, cast(byte, color))
		#	
		#	if revX:
		#		x -= w
		#	else:
		#		x += w
		#	if revY:
		#		y -= h
		#	else:
		#		y += h
		#	
		#	if not revX and x == 320:
		#		x -= w
		#		revX = true
		#	elif revX and x == -20:
		#		x = 0
		#		revX = false
		#	if not revY and y == 200:
		#		y -= h
		#		revY = true
		#	elif revY and y == -20:
		#		y = 0
		#		revY = false
		#	
		#	color = (color + 1) & 0xFF
		
		video.Graphical = false
