namespace Renraku.Kernel

import System

static class Arp:
	def Resolve(net as INetworkProvider, ip as uint) as (byte):
		ret = array(byte, 6)
		
		dhcpMac = array(byte, 6)
		for i in range(6):
			dhcpMac[i] = 0xFF
		phys = EthernetStream(net, dhcpMac, 0x0806)
		
		buf = array(byte, 28)
		
		buf[1] = 1 # Ethernet
		buf[2] = 0x80 # IP
		
		buf[4] = 6
		buf[5] = 4
		buf[7] = 1
		
		Array.Copy(net.Mac, 0, buf, 8, 6)
		
		buf[24] = ip >> 24
		buf[25] = (ip >> 16) & 0xFF
		buf[26] = (ip >> 8) & 0xFF
		buf[27] = ip & 0xFF
		
		phys.Write(buf, 0, 28)
		
		tbuf = array(byte, 28)
		phys.Read(tbuf, 0, 28)
		Array.Copy(tbuf, 18, ret, 0, 6)
		
		return ret
