namespace Renraku.Apps

import System
import Renraku.Kernel

class HalStatus(Application):
	override Name as string:
		get:
			return 'halstatus'
	
	def Run(_ as (string)):
		Hal.PrintStatus()
