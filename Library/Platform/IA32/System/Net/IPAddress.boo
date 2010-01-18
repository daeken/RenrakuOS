namespace System.Net

class IPAddress:
	Bytes as (byte)
	
	def constructor(bytes as (byte)):
		Bytes = bytes
	
	static def Parse(ip as string) as IPAddress:
		bytes = array(byte, 4)
		
		pos = 0
		i = 0
		while i < ip.Length:
			if ip[i] == char('.'):
				++pos
				++i
				continue
			
			bytes[pos] *= 10
			bytes[pos] += cast(int, ip[i]) - 48 # '0'
			
			++i
		
		return IPAddress(bytes)
	
	def GetAddressBytes() as (byte):
		return Bytes
