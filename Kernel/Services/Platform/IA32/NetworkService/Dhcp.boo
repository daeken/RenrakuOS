namespace Renraku.Kernel

import System
import System.Net

class Dhcp:
	Udp as UdpConnection
	XId as (byte)
	
	ClientIp as IPAddress
	
	def constructor():
		udpService = cast(UdpService, Context.Service['udp'])
		Udp = udpService.Connect(68, IPAddress.Parse('255.255.255.255'), 67, null)
		
		XId = array(byte, 4)
		# FIXME: Should be random
		XId[0] = 0xDE
		XId[1] = 0xAD
		XId[2] = 0xBE
		XId[3] = 0xEF
		
		options = array(byte, 10)
		
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
		
		options[9] = 0xFF # End
		
		Send(options)
		
		options = Read()
		if cast(object, options) == null:
			print 'No IP'
		else:
			print 'IP assigned'
			netService = cast(INetworkProvider, Context.Service['network'])
			netService.Ip = ClientIp
	
	def Read() as (byte):
		while true:
			buf = Udp.Recv()
			
			if buf[4] != XId[0] or buf[5] != XId[1] or buf[6] != XId[2] or buf[7] != XId[3]:
				continue
			
			ip = array(byte, 4)
			Array.Copy(buf, 16, ip, 0, 4)
			ClientIp = IPAddress(ip)
			
			options = array(byte, buf.Length - 240)
			Array.Copy(buf, 240, options, 0, buf.Length - 240)
			return options
	
	def Send(options as (byte)):
		buf = array(byte, 240 + options.Length)
		
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
		
		Udp.Send(buf)
