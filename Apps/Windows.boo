namespace Renraku.Apps

import Renraku.Kernel

class Windows(Application):
	override Name as string:
		get:
			return 'windows'
	
	def Run(_ as (string)):
		keyboard = cast(IKeyboardProvider, Context.Service['keyboard'])
		Gui = cast(IGuiProvider, Context.Service['gui'])
		Gui.StartGui()
		
		Gui.CreateNewWindow(0, 0, 50, 50, "title")
		Gui.CreateNewWindow(30, 30, 50, 50, "title")
		Gui.CreateNewWindow(60, 60, 50, 50, "title")