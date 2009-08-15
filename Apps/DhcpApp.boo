namespace Renraku.Apps

import System
import Renraku.Kernel

class DhcpApp(Application):
	override Name as string:
		get:
			return 'dhcp'
	
	def Run(_ as (string)):
		Dhcp()
