namespace Renraku.Apps

import System.Drawing
import Renraku.Gui

class Logo(Application):
	override Name as string:
		get:
			return 'logo'
	
	override HelpString as string:
		get:
			return 'Logo for the GUI'
	
	def Run(_ as (string)):
		Window() do(window as Window):
			window.Title = 'Renraku!'
			window.Visible = true
			
			image = Bitmap.FromFile('Images/Logo.png')
			window.Contents = image
			window.Size = (image.Width, image.Height)
