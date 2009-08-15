namespace Renraku.Kernel

import System
import System.IO
import System.Net

class Dhcp:
	NetStream as Stream
	XId as (byte)
	
	def constructor():
		NetStream = UdpStream(68, IPAddress.Parse('255.255.255.255'), 67)
		
		XId = array(byte, 4)
		# FIXME: Should be random
		XId[0] = 0xDE
		XId[1] = 0xAD
		XId[2] = 0xBE
		XId[3] = 0xEF
		
		options = array(byte, 9)
		
		# DHCPDISCOVER
		options[0] = 53
		options[1] = 1
		options[2] = 1
		
		# Parameter requests
		options[3] = 55
		options[4] = 4 # Count
		options[5] = 1 # Subnet mask
		options[6] = 3 # Router
		options[7] = 15 # Domain name
		options[8] = 6 # DNS
		
		Send(options)
	
	def Send(options as (byte)):
		buf = array(byte, 240 + options.Length + 1)
		
		buf[0] = 1
		buf[1] = 1
		buf[2] = 6
		buf[3] = 0
		
		Array.Copy(XId, 0, buf, 4, 4)
		
		net = cast(INetworkProvider, Context.Service['network'])
		Array.Copy(net.Mac, 0, buf, 28, 6)
		
		buf[236] = 0x63
		buf[237] = 0x82
		buf[238] = 0x53
		buf[239] = 0x63
		
		Array.Copy(options, 0, buf, 240, options.Length)
		
		buf[240 + options.Length] = 255 # End
		
		NetStream.Write(buf, 0, buf.Length)
