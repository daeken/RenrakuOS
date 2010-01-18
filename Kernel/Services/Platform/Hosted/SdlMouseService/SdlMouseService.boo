namespace Renraku.Kernel

import SdlDotNet.Core
#import SdlDotNet.Input

public interface IMouseProvider:
	event Motion as callable(int, int)
	event Button as callable(bool, int)

public static class MouseProvider:
	public Service as IMouseProvider:
		get:
			return cast(IMouseProvider, Context.Service['mouse'])

public class SdlMouseService(IService, IMouseProvider):
	override ServiceId:
		get:
			return 'mouse'
	
	event Motion as callable(int, int)
	event Button as callable(bool, int)
	
	def constructor():
		Context.Register(self)
		
		initial = true
		Events.MouseMotion += do(_, evt):
			if initial:
				initial = false
			else:
				Motion(evt.RelativeX, evt.RelativeY)
		
		Events.MouseButtonDown += do(_, evt):
			Button(true, cast(int, evt.Button))
		Events.MouseButtonUp += do(_, evt):
			Button(false, cast(int, evt.Button))
		
		print 'SDL mouse service initialized.'
