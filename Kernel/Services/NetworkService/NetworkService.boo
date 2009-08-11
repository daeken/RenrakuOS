namespace Renraku.Kernel

import System.Collections

interface INetworkDevice:
	pass

interface INetworkProvider:
	def AddDevice(device as INetworkDevice):
		pass

class NetworkService(INetworkProvider, IService):
	override ServiceId:
		get:
			return 'network'
	
	Devices as ArrayList
	def constructor():
		Devices = ArrayList()
		
		Context.Register(self)
		print 'Network service initialized.'
		
		PCNet()
	
	def AddDevice(device as INetworkDevice):
		Devices.Add(device)
