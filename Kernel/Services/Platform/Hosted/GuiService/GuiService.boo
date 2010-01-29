namespace Renraku.Kernel

import System.Drawing
import Renraku.Gui

public interface IGuiProvider:
	def Start() as void:
		pass
	
	def Add(window as IWindow):
		pass

public static class GuiProvider:
	public Service as IGuiProvider:
		get:
			return cast(IGuiProvider, Context.Service['gui'])

class GuiPointer(IWindow):
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
	
	public ClickOffset as (int)
	
	Image as Bitmap
	
	def constructor(x as int, y as int):
		Position = (x, y)
		
		Image = Bitmap.FromFile('Images/Pointer.png')
		
		ClickOffset = (-1, -1)
		#for x in range(Image.Width):
		#	for y in range(Image.Height):
		#		pixel = Image.Pixels[x, y]
		#		if pixel.A != 0 and (pixel.R != 0 or pixel.G != 0 or pixel.B != 0):
		#			ClickOffset[0] = x
		#			break
		#	if ClickOffset[0] != -1:
		#		break
		#for y in range(Image.Width):
		#	for x in range(Image.Height):
		#		pixel = Image.Pixels[x, y]
		#		if pixel.A != 0 and (pixel.R != 0 or pixel.G != 0 or pixel.B != 0):
		#			ClickOffset[1] = y
		#			break
		#	if ClickOffset[1] != -1:
		#		break
	
	def Render():
		return Image

public class GuiService(IService, IGuiProvider):
	override ServiceId:
		get:
			return 'gui'
	
	Video as IVideoProvider = null
	Windows as List [of IWindow]
	DrawOrder as List [of IWindow]
	Pointer as GuiPointer
	Dragging as IWindow = null
	
	def constructor():
		Context.Register(self)
		print 'GUI service initialized.'
	
	def Start():
		if Video != null:
			return
		
		Windows = List [of IWindow]()
		DrawOrder = List [of IWindow]()
		Pointer = GuiPointer(400, 300)
		
		Video = VideoProvider.Service
		Video.SetMode(800, 600, 24)
		Video.Tick += Tick
		Mouse = MouseProvider.Service
		#Mouse.Button += Button
		Mouse.Motion += Motion
	
	def Tick():
		screen = Bitmap(800, 600, Color.LightBlue)
		lock Windows:
			for window in DrawOrder:
				if not window.Visible:
					continue
				bitmap = window.Render()
				if bitmap != null:
					screen.Blit(window.Position[0], window.Position[1], bitmap)
		
		window = Pointer
		screen.Blit(window.Position[0], window.Position[1], window.Render())
		Video.Update(screen)
	
	def Add(window as IWindow):
		lock Windows:
			Windows.Add(window)
			DrawOrder.Add(window)
	
	def Motion(x as int, y as int):
		Pointer.Position[0] += x
		Pointer.Position[1] += y
