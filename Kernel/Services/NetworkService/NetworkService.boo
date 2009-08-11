namespace Renraku.Kernel

interface INetworkDevice:
	def Send(data as (byte)):
		pass
	
	def Recv() as (byte):
		pass

interface INetworkProvider:
	def AddDevice(device as INetworkDevice):
		pass
	
	def Send(data as (byte)) as bool:
		pass

class NetworkService(INetworkProvider, IService):
	override ServiceId:
		get:
			return 'network'
	
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
