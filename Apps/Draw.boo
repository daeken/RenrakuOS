namespace Renraku.Apps

import Renraku.Kernel

class Draw(Application):
	override Name as string:
		get:
			return 'draw'

	override HelpString as string:
		get:
			return 'VGA test capsule'
	
	def Run(_ as (string)):
		keyboard = cast(IKeyboardProvider, Context.Service['keyboard'])
		video = cast(IVideoProvider, Context.Service['video'])
		
		video.Graphical = true
		
		x = 0
		y = 0
		w = 20
		h = 20
		revX = false
		revY = false
		while not keyboard.HasData():
			for i in range(1000000):
				pass
			if revX:
				x -= w
			else:
				x += w
			if revY:
				y -= h
			else:
				y += h
			
			if not revX and x == 320:
				x -= w
				revX = true
			elif revX and x == -20:
				x = 0
				revX = false
			if not revY and y == 200:
				y -= h
				revY = true
			elif revY and y == -20:
				y = 0
				revY = false
			
			video.Clear()
			video.Fill(x, y, w, h, 4)
			video.SwapBuffers()
		
		video.Graphical = false
