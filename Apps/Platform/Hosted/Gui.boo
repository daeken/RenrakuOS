namespace Renraku.Apps

import Renraku.Kernel

class Gui(Application):
	override Name as string:
		get:
			return 'gui'
	
	override HelpString as string:
		get:
			return 'Starts the Renraku GUI'
	
	def Run(_ as (string)):
		guiServ = GuiProvider.Service
		guiServ.Start()
		
		Tasks().Run(null)
		Logo().Run(null)
		#GuiTest().Run(null)
