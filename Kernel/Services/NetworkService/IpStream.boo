namespace Renraku.Kernel

import System
import System.IO

class IpStream(Stream):
	PhyStream as Stream
	SrcAddr as uint
	DestAddr as uint
	Protocol as int
	def constructor(phyStream as Stream, srcAddr as uint, destAddr as uint, protocol as int):
		PhyStream = phyStream
		SrcAddr = srcAddr
		DestAddr = destAddr
		Protocol = protocol
	
	def Write(data as (byte), offset as int, count as int):
		buf = array(byte, 20 + count)
		
		buf[0] = (5 << 4) | 4
		buf[2] = buf.Length >> 8
		buf[3] = buf.Length & 0xFF
		
		buf[8] = 255
		buf[9] = Protocol
		
		buf[12] = SrcAddr >> 24
		buf[13] = (SrcAddr >> 16) & 0xFF
		buf[14] = (SrcAddr >> 8) & 0xFF
		buf[15] = SrcAddr & 0xFF
		
		buf[16] = DestAddr >> 24
		buf[17] = (DestAddr >> 16) & 0xFF
		buf[18] = (DestAddr >> 8) & 0xFF
		buf[19] = DestAddr & 0xFF
		
		csum = 0
		i = 0
		while i < 20:
			csum += (buf[i] << 8) | buf[i+1]
			csum &= 0xFFFF
			i += 2
		csum = ~csum
		
		buf[10] = csum >> 8
		buf[11] = csum & 0xFF
		Array.Copy(data, offset, buf, 20, count)
		
		PhyStream.Write(buf, 0, buf.Length)
