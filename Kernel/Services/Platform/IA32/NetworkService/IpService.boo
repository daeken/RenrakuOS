namespace Renraku.Kernel

import System
import System.Collections
import System.Net

callable IpRecvCallable(data as (byte)) as void

class IpConnection:
	SrcAddr as IPAddress
	public DestAddr as IPAddress
	public Protocol as int
	public OnRecv as IpRecvCallable
	Eth as EthernetConnection
	
	def constructor(destAddr as IPAddress, protocol as int, onRecv as IpRecvCallable):
		ethService = cast(EthernetService, Context.Service['ethernet'])
		ip = cast(IpService, Context.Service['ip'])
		
		destMac = Arp().Resolve(destAddr)
		Eth = ethService.Connect(destMac, 0x0800, ip.Recv)
		
		SrcAddr = ip.SrcAddr
		DestAddr = destAddr
		Protocol = protocol
		OnRecv = onRecv
	
	def Send(data as (byte)):
		buf = array(byte, 20 + data.Length)
		
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
		Array.Copy(data, 0, buf, 20, data.Length)
		
		Eth.Send(buf)

class IpService(IService):
	override ServiceId:
		get:
			return 'ip'
	
	public SrcAddr as IPAddress
	Connections as ArrayList
	
	def constructor():
		net = cast(INetworkProvider, Context.Service['network'])
		SrcAddr = net.Ip
		Connections = ArrayList()
		
		Context.Register(self)
	
	def Connect(destAddr as IPAddress, protocol as int, onRecv as IpRecvCallable) as IpConnection:
		conn = IpConnection(destAddr, protocol, onRecv)
		Connections.Add(conn)
		return conn
	
	def Recv(data as (byte)):
		i = 0
		while i < Connections.Count:
			conn = cast(IpConnection, Connections[i++])
			if conn.Protocol != data[9]:
				continue
			
			packet = array(byte, data.Length - 20)
			Array.Copy(data, 20, packet, 0, data.Length - 20)
			conn.OnRecv(packet)
