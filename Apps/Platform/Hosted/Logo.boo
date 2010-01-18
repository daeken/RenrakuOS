namespace Renraku.Apps

import Renraku.Kernel

class Logo(Application):
	override Name as string:
		get:
			return 'logo'
	
	override HelpString as string:
		get:
			return 'Logo for the GUI'
	
	def Run(_ as (string)):
		gui = GuiProvider.Service
		
		gui.CreateWindow() do(window as Window):
			window.Title = 'Renraku!'
			window.Visible = true
			
			window.Contents = Image.FromFile('Images/Logo.png')
			window.Dimensions = (400, 150)
