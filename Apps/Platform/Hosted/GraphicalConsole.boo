namespace Renraku.Apps

import Renraku.Kernel

class GraphicalConsole(Application):
	override Name as string:
		get:
			return 'gconsole'
	
	override HelpString as string:
		get:
			return 'Console for the GUI'
	
	def Run(_ as (string)):
		gui = GuiProvider.Service
		
		gui.CreateWindow() do(window as Window):
			window.Title = 'Graphical Console'
			window.Visible = true
