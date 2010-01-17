namespace Renraku.Apps

import Renraku.Kernel
import Renraku.Core.Memory

class Windows(Application):
	override Name as string:
		get:
			return 'windows'
	
	public Gui as IGuiProvider
			
	def Run(_ as (string)):
		#keyboard = cast(IKeyboardProvider, Context.Service['keyboard'])
		taskServ = cast(ITaskProvider, Context.Service['task'])
		Gui = cast(IGuiProvider, Context.Service['gui'])
		
		printhex Pointer [of uint].GetAddr(Gui)
		
		print 'services in.'
		
		taskServ.StartTask(GuiRunner, null)
		
		print 'guirunner started.'
		
		print 'creating new windows'
		Gui.CreateNewWindow(0, 0, 50, 50, "title")
		Gui.CreateNewWindow(30, 30, 50, 50, "title")
		Gui.CreateNewWindow(60, 60, 50, 50, "title")
		print 'new windows created'
		
	def GuiRunner(_ as (object)):
		printhex Pointer [of uint].GetAddr(Gui)
		print 'guirunner entered'
		Gui.StartGui()
		print 'gui started'