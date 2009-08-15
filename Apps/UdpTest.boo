namespace Renraku.Apps

import System
import System.Net
import Renraku.Kernel

class UdpTest(Application):
	override Name as string:
		get:
			return 'udp'
	
	def Run(args as (string)):
		if args.Length != 5:
			print 'Usage: udp <src ip> <src port> <dest ip> <dest port>'
			return
		
		stream = UdpStream(IPAddress.Parse(args[1]), int.Parse(args[2]), IPAddress.Parse(args[3]), int.Parse(args[4]))
		
		data = array(byte, 4)
		data[0] = 0xDE
		data[1] = 0xAD
		data[2] = 0xBE
		data[3] = 0xEF
		stream.Write(data, 0, 4)
