namespace Renraku.Kernel

import SdlDotNet.Core
import SdlDotNet.Graphics
import SdlDotNet.Input
import System.Drawing
import Boo.Lang.Builtins
import Renraku.Gui

public interface IVideoProvider:
	event Tick as callable(IVideoProvider)
	
	def SetMode(width as int, height as int, bits as int) as void:
		pass
	
	def Update(bitmap as Bitmap) as void:
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
	
	def Update(bitmap as Bitmap):
		Screen.Lock()
		i = 0
		unsafe screen as uint = Screen.Pixels:
			for y in range(bitmap.Height):
				for x in range(bitmap.Width):
					unchecked:
						*screen = bitmap.Pixels[i++].ToArgb()
					++screen
		Screen.Unlock()
		
		Screen.Update()
