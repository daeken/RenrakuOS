namespace Renraku.Kernel

import System.Net

interface INetworkDevice:
	Mac as (byte):
		get:
			pass
	
	Ip as IPAddress:
		get:
			pass
		set:
			pass
	
	def Send(data as (byte)):
		pass

callable NetworkRecvCallable(data as (byte)) as void

interface INetworkProvider:
	Mac as (byte):
		get:
			pass
	
	Ip as IPAddress:
		get:
			pass
		set:
			pass
	
	OnRecv as NetworkRecvCallable:
		set:
			pass
	
	def AddDevice(device as INetworkDevice):
		pass
	
	def Send(data as (byte)) as bool:
		pass
	
	def Recv(data as (byte)) as void:
		pass

class NetworkService(INetworkProvider, IService):
	override ServiceId:
		get:
			return 'network'
	
	Mac as (byte):
		get:
			return Device.Mac
	
	Ip as IPAddress:
		get:
			return Device.Ip
		set:
			Device.Ip = value
	
	_OnRecv as NetworkRecvCallable
	OnRecv as NetworkRecvCallable:
		set:
			_OnRecv = value
	
	Device as INetworkDevice
	def constructor():
		
		
		Context.Register(self)
		print 'Network service initialized.'
		
		Device = null
		net = PCNet()
		if net.Enabled:
			Device = net
			EthernetService()
			IpService()
			UdpService()
	
	def AddDevice(device as INetworkDevice):
		Device = device
	
	def Send(data as (byte)) as bool:
		if Device == null:
			return false
		
		Device.Send(data)
		return true
	
	def Recv(data as (byte)) as void:
		if cast(object, _OnRecv) == null:
			return
		
		_OnRecv(data)
