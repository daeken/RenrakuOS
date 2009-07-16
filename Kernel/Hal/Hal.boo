# I can't let you do that, Dave.

namespace Renraku.Kernel

enum DriverClass:
	Timer
	Keyboard
	Network

interface IDriver:
	Class as DriverClass:
		get:
			pass
	
	def PrintStatus() as void:
		pass

class Hal:
	static Instance as Hal
	
	Drivers as (IDriver)
	
	def constructor():
		Instance = self
		
		Drivers = array(IDriver, 3) # XXX: Use Enum.GetValues(DriverClass).Length
		
		print 'HAL initialized.'
	
	static def Register(driver as IDriver):
		Instance.Drivers[cast(int, driver.Class)] = driver
	
	static def GetDriver(dclass as DriverClass) as IDriver:
		return Instance.Drivers[cast(int, dclass)]
	
	static def PrintStatus():
		print 'Printing HAL status.'
		for i in range(3):
			driver = Instance.Drivers[i]
			if driver != null:
				driver.PrintStatus()
