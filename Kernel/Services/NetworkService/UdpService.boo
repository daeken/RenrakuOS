namespace Renraku.Kernel

import System
import System.Collections
import System.Net

callable UdpRecvCallable(data as (byte)) as void

class UdpConnection:
	public SrcPort as int
	public DestPort as int
	public OnRecv as UdpRecvCallable
	RecvQueue as Queue
	Ip as IpConnection
	
	def constructor(srcPort as int, destIp as IPAddress, destPort as int, onRecv as UdpRecvCallable):
		SrcPort = srcPort
		DestPort = destPort
		
		if cast(object, onRecv) == null:
			OnRecv = DoQueueRecv
			RecvQueue = Queue()
		else:
			OnRecv = onRecv
		
		Udp = cast(UdpService, Context.Service['udp'])
		ipService = cast(IpService, Context.Service['ip'])
		Ip = ipService.Connect(destIp, 0x11, Udp.Recv)
	
	def DoQueueRecv(data as (byte)):
		RecvQueue.Enqueue(data)
	
	def Recv() as (byte):
		while RecvQueue.Count == 0:
			continue
		
		return RecvQueue.Dequeue()
	
	def Send(data as (byte)):
		buf = array(byte, 8 + data.Length)
		
		buf[0] = SrcPort >> 8
		buf[1] = SrcPort & 0xFF
		buf[2] = DestPort >> 8
		buf[3] = DestPort & 0xFF
		
		buf[4] = buf.Length >> 8
		buf[5] = buf.Length & 0xFF
		
		Array.Copy(data, 0, buf, 8, data.Length)
		Ip.Send(buf)

class UdpService(IService):
	override ServiceId:
		get:
			return 'udp'
	
	Connections as ArrayList
	
	def constructor():
		Connections = ArrayList()
		
		Context.Register(self)
	
	def Connect(srcPort as int, destIp as IPAddress, destPort as int, onRecv as UdpRecvCallable):
		conn = UdpConnection(srcPort, destIp, destPort, onRecv)
		Connections.Add(conn)
		return conn
	
	def Recv(data as (byte)):
		i = 0
		while i < Connections.Count:
			conn = cast(UdpConnection, Connections[i++])
			if (
					data[0] != (conn.DestPort >> 8) or data[1] != (conn.DestPort & 0xFF) or 
					data[2] != (conn.SrcPort >> 8) or data[3] != (conn.SrcPort & 0xFF)
				):
				continue
			
			length = (data[4] << 8) | data[5]
			length -= 8 # Header
			
			buf = array(byte, length)
			Array.Copy(data, 8, buf, 0, length)
			
			conn.OnRecv(buf)
