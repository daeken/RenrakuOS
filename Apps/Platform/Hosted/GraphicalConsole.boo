namespace Renraku.Apps

import Renraku.Gui

class GraphicalConsole(Application):
	override Name as string:
		get:
			return 'gconsole'
	
	override HelpString as string:
		get:
			return 'Console for the GUI'
	
	def Run(_ as (string)):
		Window() do(window as IWindow):
			window.Visible = true
			window.Title = 'Graphical console'
