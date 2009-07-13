namespace Renraku.Kernel

class Test:
	Counter as int
	def constructor():
		print 'Test works!'
		Counter = 0
	
	def Bar(newval as int):
		if newval != 0:
			Counter = newval
		
		if Counter == 0:
			print 'Counter == 0'
		elif Counter == 1:
			print 'Counter == 1'
		else:
			print 'No idea!'
		Counter++

static class Kernel:
	def Main():
		Console.Init()
		MemoryManager.Init()
		ObjectManager.Init()
		
		print 'Renraku initialized.'
		
		obj = Test()
		obj.Bar(0)
		obj.Bar(0)
		obj.Bar(0)
		obj.Bar(1)
