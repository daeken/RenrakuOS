namespace Renraku.Kernel

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
		Screen = Video.SetVideoMode(width, height)
