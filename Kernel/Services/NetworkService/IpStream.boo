namespace Renraku.Kernel

import System
import System.IO
import System.Net

class IpStream(Stream):
	PhyStream as Stream
	SrcAddr as IPAddress
	DestAddr as IPAddress
	Protocol as int
	def constructor(destAddr as IPAddress, protocol as int):
		destMac = Arp.Resolve(destAddr)
		PhyStream = EthernetStream(destMac, 0x0800)
		
		net = cast(INetworkProvider, Context.Service['network'])
		SrcAddr = net.Ip
		DestAddr = destAddr
		Protocol = protocol
	
	def Write(data as (byte), offset as int, count as int):
		buf = array(byte, 20 + count)
		
		buf[0] = 0x45
		buf[2] = buf.Length >> 8
		buf[3] = buf.Length & 0xFF
		
		buf[8] = 255
		buf[9] = Protocol
		
		Array.Copy(SrcAddr.GetAddressBytes(), 0, buf, 12, 4)
		Array.Copy(DestAddr.GetAddressBytes(), 0, buf, 16, 4)
		
		csum = 0
		i = 0
		while i < 20:
			csum += (buf[i] << 8) | buf[i+1]
			i += 2
		while (csum & 0xFFFF0000) != 0:
			csum = (csum & 0xFFFF) + (csum >> 16)
		csum = ~csum
		
		buf[10] = csum >> 8
		buf[11] = csum & 0xFF
		Array.Copy(data, offset, buf, 20, count)
		
		PhyStream.Write(buf, 0, buf.Length)
	
	def Read(data as (byte), offset as int, count as int) as int:
		buf = array(byte, 20 + count)
		
		while true:
			if PhyStream.Read(buf, 0, 20+count) != 20+count:
				continue
			if buf[9] != Protocol:
				continue
			
			Array.Copy(buf, 20, data, offset, count)
			return count
