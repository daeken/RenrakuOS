namespace Renraku.Gui

import System.Drawing
import Renraku.Kernel

public interface IWindow(IWidget):
	HasDecorations as bool:
		get
		set
	Position as (int):
		get
		set
	Visible as bool:
		get
		set

class Window(IWindow):
	_HasDecorations as bool
	public HasDecorations as bool:
		get:
			return _HasDecorations
		set:
			_HasDecorations = value
	_Position as (int)
	public Position as (int):
		get:
			return _Position
		set:
			_Position = value
	_Visible as bool
	public Visible as bool:
		get:
			return _Visible
		set:
			_Visible = value
	
	public Size as (int)
	public Title as string
	public Contents as IWidget
	
	def constructor():
		self(null)
	
	def constructor(func as callable):
		Position = (200, 200)
		Size = (400, 200)
		Title = ''
		Visible = false
		
		if func != null:
			func(self)
		
		gui = GuiProvider.Service
		gui.Add(self)
	
	def Render() as Bitmap:
		vbox = VBox()
		label = Label(Title)
		label.BgColor = Color.Blue
		label.FgColor = Color.White
		vbox.Add(label)
		vbox.Add(Contents)
		return vbox.Render()
