namespace Renraku.Kernel

import System
import System.IO
import System.Net

class UdpStream(Stream):
	NetStream as Stream
	SrcPort as int
	DestPort as int
	def constructor(srcPort as int, destIp as IPAddress, destPort as int):
		NetStream = IpStream(destIp, 0x11)
		
		SrcPort = srcPort
		DestPort = destPort
	
	def Write(data as (byte), offset as int, count as int):
		buf = array(byte, 8 + count)
		
		buf[0] = SrcPort >> 8
		buf[1] = SrcPort & 0xFF
		buf[2] = DestPort >> 8
		buf[3] = DestPort & 0xFF
		
		buf[4] = buf.Length >> 8
		buf[5] = buf.Length & 0xFF
		
		Array.Copy(data, offset, buf, 8, count)
		
		NetStream.Write(buf, 0, buf.Length)
