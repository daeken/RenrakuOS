namespace Renraku.Kernel

import System.Drawing
import Renraku.Gui

public interface IGuiProvider:
	Windows as List [of IWindow]:
		get
	event WindowAdded as callable(IWindow)
	event WindowRemoved as callable(IWindow)
	
	def Start() as void:
		pass
	
	def Add(window as IWindow):
		pass
	
	def Focus(window as IWindow):
		pass

public static class GuiProvider:
	public Service as IGuiProvider:
		get:
			return cast(IGuiProvider, Context.Service['gui'])

class GuiPointer(IWidget):
	public ClickOffset as (int)
	
	Image as Bitmap
	
	def constructor(x as int, y as int):
		Position = (x, y)
		
		Image = Bitmap.FromFile('Images/Pointer.png')
		
		ClickOffset = (-1, -1)
		for x in range(Image.Width):
			off = x
			for y in range(Image.Height):
				pixel = Image.Pixels[off]
				if pixel.A != 0 and (pixel.R != 0 or pixel.G != 0 or pixel.B != 0):
					ClickOffset[0] = x
					break
				off += Image.Width
			if ClickOffset[0] != -1:
				break
		for y in range(Image.Width):
			off = y * Image.Width
			for x in range(Image.Height):
				pixel = Image.Pixels[off++]
				if pixel.A != 0 and (pixel.R != 0 or pixel.G != 0 or pixel.B != 0):
					ClickOffset[1] = y
					break
			if ClickOffset[1] != -1:
				break
	
	def Render():
		return Image

public class GuiService(IService, IGuiProvider):
	override ServiceId:
		get:
			return 'gui'
	
	Video as IVideoProvider = null
	_Windows as List [of IWindow]
	Windows as List [of IWindow]:
		get:
			return _Windows
		set:
			_Windows = value
	DrawOrder as List [of IWindow]
	Pointer as GuiPointer
	Dragging as IWindow = null
	
	event WindowAdded as callable(IWindow)
	event WindowRemoved as callable(IWindow)
	
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
		Mouse.Button += Button
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
			WindowAdded(window)
	
	def Motion(x as int, y as int):
		Pointer.Position[0] += x
		Pointer.Position[1] += y
		
		if Pointer.Position[0] < 0:
			Pointer.Position[0] = 0
		if Pointer.Position[1] < 0:
			Pointer.Position[1] = 0
		
		if Pointer.Position[0] >= 800:
			Pointer.Position[0] = 799
		if Pointer.Position[1] >= 600:
			Pointer.Position[1] = 599
	
	def FindWindow(x as int, y as int):
		found as IWindow = null
		for window in DrawOrder:
			if (
					window.Position[0] <= x and
					window.Position[1] <= y and
					window.Position[0] + window.Size[0] > x and
					window.Position[1] + window.Size[1] > y
				):
				found = window
		return found
	
	def Button(down as bool, button as int):
		position = (Pointer.Position[0] + Pointer.ClickOffset[0], Pointer.Position[1] + Pointer.ClickOffset[1])
		window = FindWindow(position[0], position[1])
		if window == null:
			return
		
		# Make relative to the window
		position[0] -= window.Position[0]
		position[1] -= window.Position[1]
		window.Clicked(position[0], position[1], down, button)
	
	def Focus(window as IWindow):
		lock Windows:
			DrawOrder.Remove(window)
			DrawOrder.Add(window)
