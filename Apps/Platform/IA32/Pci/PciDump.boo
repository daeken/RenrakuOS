namespace Renraku.Apps

import System
import Renraku.Kernel

class PciDump(Application):
	override Name as string:
		get:
			return 'pci'
	
	def Run(_ as (string)):
		cast(PciService, Context.Service['pci']).Scan()
