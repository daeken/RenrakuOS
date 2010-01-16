namespace Renraku.Kernel

import System
import System.Collections

callable EthernetRecvCallable(data as (byte)) as void

class EthernetConnection:
	public DestMac as (byte)
	public Type as int
	public OnRecv as EthernetRecvCallable
	Eth as EthernetService
	
	def constructor(destMac as (byte), type as int, onRecv as EthernetRecvCallable):
		DestMac = destMac
		Type = type
		OnRecv = onRecv
		
		Eth = cast(EthernetService, Context.Service['ethernet'])
	
	def Send(packet as (byte)):
		Eth.Send(packet, DestMac, Type)

class EthernetService(IService):
	override ServiceId:
		get:
			return 'ethernet'
	
	static CrcTable as (byte)
	
	Net as INetworkProvider
	SrcMac as (byte)
	Connections as ArrayList
	
	def constructor():
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
		
		Net = cast(INetworkProvider, Context.Service['network'])
		SrcMac = Net.Mac
		
		Connections = ArrayList()
		Net.OnRecv = Recv
		
		Context.Register(self)
	
	def Connect(destMac as (byte), type as int, onRecv as EthernetRecvCallable) as EthernetConnection:
		conn = EthernetConnection(destMac, type, onRecv)
		Connections.Add(conn)
		return conn
	
	def Send(data as (byte), destMac as (byte), type as int):
		buf = array(byte, 14 + data.Length)
		
		Array.Copy(destMac, 0, buf, 0, 6)
		Array.Copy(SrcMac, 0, buf, 6, 6)
		
		buf[12] = type >> 8
		buf[13] = type & 0xFF
		
		Array.Copy(data, 0, buf, 14, data.Length)
		
		Net.Send(buf)
	
	def Recv(data as (byte)):
		i = 0
		while i < Connections.Count:
			conn = cast(EthernetConnection, Connections[i++])
			if data[12] != conn.Type >> 8 or data[13] != conn.Type & 0xFF:
				continue
			match = true
			for j in range(6):
				if SrcMac[j] == data[j] and conn.DestMac[j] == data[6+j]:
					match = false
					break
			if not match:
				continue
			
			packet = array(byte, data.Length - 18)
			Array.Copy(data, 14, packet, 0, data.Length - 18)
			conn.OnRecv(packet)
