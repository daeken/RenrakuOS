namespace Renraku.Gui

import System.Drawing

public class Button(IWidget):
	ButtonLabel as Label
	Text as string:
		get:
			return ButtonLabel.Text
		set:
			ButtonLabel.Text = value
	
	event Click as callable(int)
	
	def constructor():
		self('')
	
	def constructor(text as string):
		ButtonLabel = Label(text)
	
	def Render() as Bitmap:
		return ButtonLabel.Render()
	
	def Clicked(x as int, y as int, down as bool, button as int):
		if not down:
			Click(button)
