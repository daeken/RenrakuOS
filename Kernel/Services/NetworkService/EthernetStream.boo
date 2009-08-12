namespace Renraku.Kernel

import System
import System.IO

class EthernetStream(Stream):
	static CrcTable as (byte)
	
	Net as INetworkProvider
	SrcMac as (byte)
	DestMac as (byte)
	Type as int
	def constructor(net as INetworkProvider, destMac as (byte), type as int):
		if cast(object, CrcTable) == null:
			CrcTable = array(byte, 256)
			for i in range(256):
				temp = i
				j = 0
				while j++ < 8:
					if temp & 1 == 1:
						temp = (temp >> 1) ^ 0x04C11DB7
					else:
						temp >>= 1
				CrcTable[i] = temp
		
		Net = net
		SrcMac = Net.Mac
		DestMac = destMac
		Type = type
	
	def Write(data as (byte), offset as int, count as int):
		buf = array(byte, 14 + count + 4)
		
		Array.Copy(DestMac, 0, buf, 0, 6)
		Array.Copy(SrcMac, 0, buf, 6, 6)
		
		buf[12] = Type >> 8
		buf[13] = Type & 0xFF
		
		Array.Copy(data, offset, buf, 14, count)
		
		j = 0
		length = 14 + count
		crc = 0xFFFFFFFF
		while j < length:
			index = (crc & 0xFF) ^ buf[j]
			crc = (crc >> 8) ^ CrcTable[index]
			++j
		
		buf[length] = crc >> 24
		buf[length+1] = (crc >> 16) & 0xFF
		buf[length+2] = (crc >> 8) & 0xFF
		buf[length+3] = crc & 0xFF
		
		Net.Send(buf)
	
	def Read(data as (byte), offset as int, count as int) as int:
		while true:
			buf = Net.Read()
			
			match = true
			for i in range(6):
				if SrcMac[i] == data[i] and DestMac[i] == data[6+i]:
					match = false
					break
			if not match or buf[12] != Type >> 8 or buf[13] != Type & 0xFF:
				continue
			
			length = buf.Length - 18
			if count < length:
				length = count
			
			Array.Copy(buf, 14, data, offset, length)
			
			return length
