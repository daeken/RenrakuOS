namespace Renraku.Apps

import Renraku.Kernel

class Mouse(Application):
	override Name as string:
		get:
			return 'mouse'
	
	def Run(_ as (string)):
		keyboard = cast(IKeyboardProvider, Context.Service['keyboard'])
		mouse = cast(IMouseProvider, Context.Service['mouse'])
		video = cast(IVideoProvider, Context.Service['video'])
		
		video.Graphical = true
		
		x = 160
		y = 100
		color = 4
		while not keyboard.HasData():
			video.Clear()
			video.Fill(x-5, y-5, 10, 10, color)
			video.SwapBuffers()
			
			while true:
				evt = mouse.Read()
				if evt == null:
					break
				
				if evt.Type == MouseEventType.ButtonDown:
					color |= evt.Button
				elif evt.Type == MouseEventType.ButtonUp:
					color &= ~evt.Button
				elif evt.Type == MouseEventType.Movement:
					if evt.Delta[0] < 0:
						x -= (-evt.Delta[0]) >> 1
					else:
						x += evt.Delta[0] >> 1
					if evt.Delta[1] < 0:
						y += (-evt.Delta[1]) >> 1
					else:
						y -= evt.Delta[1] >> 1
					
					if x > 315:
						x = 315
					elif x < 5:
						x = 5
					if y > 195:
						y = 195
					elif y < 5:
						y = 5
		
		video.Graphical = false
