namespace Renraku.Apps

import System
import System.Net
import Renraku.Kernel

class ArpTest(Application):
	override Name as string:
		get:
			return 'arp'
	
	def Run(args as (string)):
		if args.Length == 1:
			ip = '192.168.1.7'
		else:
			ip = args[1]
		
		mac = Arp().Resolve(IPAddress.Parse(ip))
		for i in range(6):
			printhex mac[i]
