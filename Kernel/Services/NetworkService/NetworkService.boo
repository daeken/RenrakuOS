namespace Renraku.Kernel

interface INetworkDevice:
	Mac as (byte):
		get:
			pass
	
	def Send(data as (byte)):
		pass
	
	def Recv() as (byte):
		pass

interface INetworkProvider:
	Mac as (byte):
		get:
			pass
	
	def AddDevice(device as INetworkDevice):
		pass
	
	def Send(data as (byte)) as bool:
		pass
	
	def Read() as (byte):
		pass

class NetworkService(INetworkProvider, IService):
	override ServiceId:
		get:
			return 'network'
	
	Mac as (byte):
		get:
			return Device.Mac
	
	Device as INetworkDevice
	def constructor():
		Device = null
		
		Context.Register(self)
		print 'Network service initialized.'
		
		PCNet()
	
	def AddDevice(device as INetworkDevice):
		Device = device
	
	def Send(data as (byte)) as bool:
		if Device == null:
			return false
		
		Device.Send(data)
		return true
	
	def Read() as (byte):
		if Device == null:
			return null
		
		return Device.Recv()
