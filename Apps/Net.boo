namespace Renraku.Apps

import System
import Renraku.Kernel

class NetTest(Application):
	override Name as string:
		get:
			return 'net'
	
	def Run(_ as (string)):
		net = cast(INetworkProvider, Context.Service['network'])
		
		buf = array(byte, 128)
		buf[0] = 0xDE
		buf[1] = 0xAD
		buf[2] = 0xBE
		buf[3] = 0xEF
		net.Send(buf)
