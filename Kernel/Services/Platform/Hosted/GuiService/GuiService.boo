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

public class GuiService(IService, IGuiProvider):
	override ServiceId:
		get:
			return 'gui'
	
	Video as IVideoProvider = null
	Windows as List [of IWindow]
	DrawOrder as List [of IWindow]
	Pointer as (int)
	Dragging as IWindow = null
	
	def constructor():
		Context.Register(self)
		print 'GUI service initialized.'
	
	def Start():
		if Video != null:
			return
		
		Windows = List [of IWindow]()
		DrawOrder = List [of IWindow]()
		Pointer = (200, 300)
		
		Video = VideoProvider.Service
		Video.SetMode(800, 600, 24)
		Video.Tick += Tick
		#Mouse = MouseProvider.Service
		#Mouse.Button += Button
		#Mouse.Motion += Motion
	
	def Tick():
		screen = Bitmap(800, 600, Color.LightBlue)
		lock Windows:
			for window in DrawOrder:
				if not window.Visible:
					continue
				bitmap = window.Render()
				if bitmap != null:
					screen.Blit(window.Position[0], window.Position[1], bitmap)
		
		Video.Update(screen)
	
	def Add(window as IWindow):
		lock Windows:
			Windows.Add(window)
			DrawOrder.Add(window)
