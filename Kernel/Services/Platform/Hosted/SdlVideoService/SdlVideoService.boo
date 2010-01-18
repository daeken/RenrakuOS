namespace Renraku.Kernel

import SdlDotNet.Core
import SdlDotNet.Graphics
import SdlDotNet.Graphics.Primitives
import SdlDotNet.Input
import System.Drawing

public interface IVideoProvider:
	event Tick as callable(IVideoProvider)
	
	def SetMode(width as int, height as int, bits as int) as void:
		pass
	
	def DrawLine(x1 as int, y1 as int, x2 as int, y2 as int, color as Color):
		pass
	
	def DrawRect(x1 as int, y1 as int, x2 as int, y2 as int, lineColor as Color, fillColor as Color):	
		pass
	
	def SwapBuffers():
		pass

public static class VideoProvider:
	public Service as IVideoProvider:
		get:
			return cast(IVideoProvider, Context.Service['video'])

public class SdlVideoService(IService, IVideoProvider):
	override ServiceId:
		get:
			return 'video'
	
	Screen as Surface = null
	public event Tick as callable(IVideoProvider)
	
	def constructor():
		Context.Register(self)
		print 'SDL video service initialized.'
	
	def SetMode(width as int, height as int, bits as int) as void:
		taskServ = cast(ITaskProvider, Context.Service['task'])
		taskServ.StartTask() do:
			Video.WindowIcon()
			Screen = Video.SetVideoMode(width, height)
			Video.WindowCaption = 'Renraku'
			Mouse.ShowCursor = false
			
			Events.Quit += do(sender, e):
				Events.QuitApplication()
			Events.Tick += do(sender, e):
				Tick(self)
			Events.Run()
	
	def DrawLine(x1 as int, y1 as int, x2 as int, y2 as int, color as Color):
		Screen.Draw(
				Line(x1, y1, x2, y2), 
				color
			)
	
	def DrawRect(x1 as int, y1 as int, x2 as int, y2 as int, lineColor as Color, fillColor as Color):	
		DrawLine(x1, y1, x1, y2, lineColor) # Left
		DrawLine(x1, y1, x2, y1, lineColor) # Top
		DrawLine(x2, y1, x2, y2, lineColor) # Right
		DrawLine(x1, y2, x2, y2, lineColor) # Bottom
		
		Screen.Fill(
				Rectangle(
						x1+1, y1+1, 
						x2-x1-1, y2-y1-1
					), 
				fillColor
			)
	
	def SwapBuffers():
		Screen.Update()
		Screen.Fill(Color.LightBlue)
