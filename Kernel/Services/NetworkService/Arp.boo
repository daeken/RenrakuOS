namespace Renraku.Kernel

import System
import System.Net

class Arp:
	Ret as (byte)
	
	def Resolve(ip as IPAddress) as (byte):
		ipBytes = ip.GetAddressBytes()
		if (
				ipBytes[0] == 0xFF and ipBytes[1] == 0xFF and 
				ipBytes[2] == 0xFF and ipBytes[3] == 0xFF
			):
			Ret = array(byte, 6)
			Ret[0] = 0xFF
			Ret[1] = 0xFF
			Ret[2] = 0xFF
			Ret[3] = 0xFF
			Ret[4] = 0xFF
			Ret[5] = 0xFF
			return Ret
		
		dhcpMac = array(byte, 6)
		for i in range(6):
			dhcpMac[i] = 0xFF
		
		eth = cast(EthernetService, Context.Service['ethernet'])
		conn = eth.Connect(dhcpMac, 0x0806, Recv)
		
		buf = array(byte, 28)
		
		buf[1] = 1 # Ethernet
		buf[2] = 8 # IP
		
		buf[4] = 6
		buf[5] = 4
		buf[7] = 1
		
		net = cast(INetworkProvider, Context.Service['network'])
		Array.Copy(net.Mac, 0, buf, 8, 6)
		Array.Copy(ipBytes, 0, buf, 24, 4)
		
		conn.Send(buf)
		
		while cast(object, Ret) == null:
			pass
		
		return Ret
	
	def Recv(buf as (byte)):
		tret = array(byte, 6)
		Array.Copy(buf, 8, tret, 0, 6)
		Ret = tret
