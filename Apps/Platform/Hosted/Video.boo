namespace Renraku.Apps

import Renraku.Kernel

class Video(Application):
	override Name as string:
		get:
			return 'video'
	
	override HelpString as string:
		get:
			return 'Hosted video test'
	
	def Run(_ as (string)):
		videoServ = cast(IVideoProvider, Context.Service['video'])
		videoServ.SetMode(640, 480, 24)
