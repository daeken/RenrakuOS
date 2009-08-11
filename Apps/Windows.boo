namespace Renraku.Apps

import Renraku.Kernel

class Windows(Application):
	override Name as string:
		get:
			return 'windows'
	
	public Gui as IGuiProvider
			
	def Run(_ as (string)):
		keyboard = cast(IKeyboardProvider, Context.Service['keyboard'])
		taskServ = cast(ITaskProvider, Context.Service['task'])
		Gui = cast(IGuiProvider, Context.Service['gui'])
		
		taskServ.StartTask(GuiRunner, null)
		
		Gui.CreateNewWindow(0, 0, 50, 50, "title")
		Gui.CreateNewWindow(30, 30, 50, 50, "title")
		Gui.CreateNewWindow(60, 60, 50, 50, "title")
		
	def GuiRunner(_ as (object)):
		Gui.StartGui()