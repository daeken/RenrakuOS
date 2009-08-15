namespace Renraku.Kernel

import System
import System.Net

static class Arp:
	def Resolve(ip as IPAddress) as (byte):
		ret = array(byte, 6)
		
		ipBytes = ip.GetAddressBytes()
		if (
				ipBytes[0] == 0xFF and ipBytes[1] == 0xFF and 
				ipBytes[2] == 0xFF and ipBytes[3] == 0xFF
			):
			ret[0] = 0xFF
			ret[1] = 0xFF
			ret[2] = 0xFF
			ret[3] = 0xFF
			ret[4] = 0xFF
			ret[5] = 0xFF
			return ret
		
		dhcpMac = array(byte, 6)
		for i in range(6):
			dhcpMac[i] = 0xFF
		phys = EthernetStream(dhcpMac, 0x0806)
		
		buf = array(byte, 28)
		
		buf[1] = 1 # Ethernet
		buf[2] = 8 # IP
		
		buf[4] = 6
		buf[5] = 4
		buf[7] = 1
		
		net = cast(INetworkProvider, Context.Service['network'])
		Array.Copy(net.Mac, 0, buf, 8, 6)
		Array.Copy(ipBytes, 0, buf, 24, 4)
		
		phys.Write(buf, 0, 28)
		
		tbuf = array(byte, 28)
		phys.Read(tbuf, 0, 28)
		Array.Copy(tbuf, 8, ret, 0, 6)
		
		return ret
