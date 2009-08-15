namespace Renraku.Apps

import System
import System.Net
import Renraku.Kernel

class UdpTest(Application):
	override Name as string:
		get:
			return 'udp'
	
	def Run(args as (string)):
		if args.Length != 4:
			print 'Usage: udp <src port> <dest ip> <dest port>'
			return
		
		stream = UdpStream(int.Parse(args[1]), IPAddress.Parse(args[2]), int.Parse(args[3]))
		
		data = array(byte, 4)
		data[0] = 0xDE
		data[1] = 0xAD
		data[2] = 0xBE
		data[3] = 0xEF
		stream.Write(data, 0, 4)
