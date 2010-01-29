namespace Renraku.Apps

import Renraku.Gui

class GuiTest(Application):
	override Name as string:
		get:
			return 'gtest'
	
	override HelpString as string:
		get:
			return 'Test app for the GUI/toolkit'
	
	def Run(_ as (string)):
		Window('Gui Test') do(window as IWindow):
			window.Visible = true
			
			vbox = window.Contents = VBox()
			vbox.Add(Label('Gui test!'))
			
			hbox = HBox()
			hbox.Add(Label('Click me -->'))
			button = Button('Foo!')
			hbox.Add(button)
			vbox.Add(hbox)
			
			button.Click += do(button):
				print 'Foo clicked!'
