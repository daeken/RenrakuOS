namespace Renraku.Kernel

import SdlDotNet.Core
import SdlDotNet.Graphics

public interface IVideoProvider:
	def SetMode(width as int, height as int, bits as int) as void:
		pass

public class SdlVideoService(IService, IVideoProvider):
	override ServiceId:
		get:
			return 'video'
	
	Screen as Surface = null
	
	def constructor():
		Context.Register(self)
		print 'SDL video service initialized.'
	
	def SetMode(width as int, height as int, bits as int) as void:
		if Screen == null:
			Screen = Video.SetVideoMode(width, height)
			SetupEvents()
		else:
			Screen = Video.SetVideoMode(width, height)
	
	def SetupEvents():
		taskServ = cast(ITaskProvider, Context.Service['task'])
		Events.Quit += do(sender, e):
			Events.QuitApplication()
		Events.Tick += do(sender, e):
			Screen.Update()
		taskServ.StartTask(Events.Run, null)
