namespace Renraku.Apps

import System.Drawing
import Renraku.Kernel
import Renraku.Gui

class Tasks(Application):
	override Name as string:
		get:
			return 'tasks'
	
	override HelpString as string:
		get:
			return 'Task switcher for the GUI'
	
	def Run(_ as (string)):
		Window() do(window as Window):
			window.Frameless = true
			window.Title = 'Task switcher'
			window.Visible = true
			window.Position = (0, 0)
			
			window.Contents = windowbox = VBox()
			gui = GuiProvider.Service
			def AddWindow(_window as IWindow):
				if _window != window:
					button = Button(_window.Title)
					button.Click += do(button):
						if button == 1:
							gui.Focus(_window)
					windowbox.Add(button)
			
			for _window in gui.Windows:
				AddWindow(_window)
			gui.WindowAdded += AddWindow
