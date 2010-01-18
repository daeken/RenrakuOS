namespace Renraku.Kernel

#import SdlDotNet.Core

public interface IKeyboardProvider:
	pass

public static class KeyboardProvider:
	public Service as IKeyboardProvider:
		get:
			return cast(IKeyboardProvider, Context.Service['keyboard'])

public class SdlKeyboardService(IService, IKeyboardProvider):
	override ServiceId:
		get:
			return 'keyboard'
	
	def constructor():
		Context.Register(self)
		print 'SDL keyboard service initialized.'
