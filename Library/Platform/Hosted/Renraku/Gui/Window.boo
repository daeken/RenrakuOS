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

static class WindowTheme:
	public TopLeft as IWidget = Bitmap.FromFile('Images/Theme/window_corner_top_left.png')
	public TopRight as IWidget = Bitmap.FromFile('Images/Theme/window_corner_top_right.png')
	public BottomLeft as IWidget = Bitmap.FromFile('Images/Theme/window_corner_bottom_left.png')
	public BottomRight as IWidget = Bitmap.FromFile('Images/Theme/window_corner_bottom_right.png')
	
	_Left as IWidget = Bitmap.FromFile('Images/Theme/window_side_left.png')
	public Left as IWidget:
		get:
			_Left.Expandable = true
			return _Left
	_Right as IWidget = Bitmap.FromFile('Images/Theme/window_side_right.png')
	public Right as IWidget:
		get:
			_Right.Expandable = true
			return _Right

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
			_Contents = value
			Body.Add(1, 1, _Contents)
	
	TitleLabel as Label
	Body as Grid
	
	def constructor():
		self(null)
	
	def constructor(func as callable(IWindow)):
		TitleLabel = Label()
		
		Position = (-1, -1)
		Size = (400, 200)
		Title = ''
		Visible = false
		Frameless = false
		
		Body = Grid()
		TitleLabel.FgColor = Color.White
		Body.Add(0, 0, WindowTheme.TopLeft)
		Body.Add(1, 0, TitleLabel)
		Body.Add(2, 0, WindowTheme.TopRight)
		Body.Add(0, 2, WindowTheme.BottomLeft)
		Body.Add(2, 2, WindowTheme.BottomRight)
		
		Body.Add(0, 1, WindowTheme.Left)
		Body.Add(2, 1, WindowTheme.Right)
		
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
