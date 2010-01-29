namespace Renraku.Gui

import System
import System.Drawing
import Renraku.Kernel

public abstract class IWindow(IWidget):
	public Visible as bool
	public Frameless as bool
	
	public abstract Contents as IWidget:
		get:
			pass
		set:
			pass
	
	public abstract Title as string:
		get:
			pass
		set:
			pass

class Window(IWindow):
	_Title as string
	public Title as string:
		get:
			return _Title
		set:
			_Title = value
			TitleLabel.Text = value
	_Contents as IWidget
	public Contents as IWidget:
		get:
			return _Contents
		set:
			if _Contents != null:
				Body.Remove(_Contents)
			_Contents = value
			Body.Add(_Contents)
	
	TitleLabel as Label
	Body as VBox
	
	def constructor():
		self(null)
	
	def constructor(func as callable(IWindow)):
		TitleLabel = Label()
		
		Position = (-1, -1)
		Size = (400, 200)
		Title = ''
		Visible = false
		Frameless = false
		
		Body = VBox()
		TitleLabel.FgColor = Color.White
		Body.Add(TitleLabel)
		
		if func != null:
			func(self)
		
		if Position[0] == -1 and Position[1] == -1:
			rnd = Random()
			Position[0] = rnd.Next(0, 800-Size[0])
			Position[1] = rnd.Next(0, 600-Size[1])
		
		gui = GuiProvider.Service
		gui.Add(self)
	
	def constructor(title as string, func as callable(IWindow)):
		self() do(window as IWindow):
			window.Title = title
			if func != null:
				func(window)
	
	def Render() as Bitmap:
		if not Frameless:
			image = Body.Render()
		else:
			image = Contents.Render()
		Size = (image.Width, image.Height)
		return image
	
	def Clicked(x as int, y as int, down as bool, button as int):
		if not Frameless:
			Body.Clicked(x, y, down, button)
		else:
			Contents.Clicked(x, y, down, button)
