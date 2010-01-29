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
			
			window.Contents = Grid() do(grid as Grid):
				grid.Add(0, 0, Label('These are some'))
				grid.Add(1, 0, Label('1, 0'))
				grid.Add(2, 0, Label('2, 0'))
				
				grid.Add(0, 1, Label('0, 1'))
				grid.Add(1, 1, Label('abnormally long'))
				grid.Add(2, 1, Label('2, 1'))
				
				grid.Add(0, 2, Label('Oh\nHey\nI\'m\na\nreaaaaaalllly\nlong\ncell'))
				grid.Add(1, 2, Label('1, 2'))
				grid.Add(2, 2, Label('grid cells!!!!!'))
			
			#vbox = window.Contents = VBox()
			#vbox.Add(Label('Gui test!'))
			
			#hbox = HBox()
			#hbox.Add(Label('Click me -->'))
			#button = Button('Foo!')
			#hbox.Add(button)
			#vbox.Add(hbox)
			
			#button.Click += do(button):
			#	print 'Foo clicked!'
