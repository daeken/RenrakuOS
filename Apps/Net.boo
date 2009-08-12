namespace Renraku.Apps

import System
import Renraku.Kernel

class NetTest(Application):
	override Name as string:
		get:
			return 'net'
	
	def Run(_ as (string)):
		net = cast(INetworkProvider, Context.Service['network'])
		
		while true:
			Arp.Resolve(net, 0x7b2d4359)
			print 'Resolved!'
