namespace Renraku.Apps

import Renraku.Kernel

class Task(Application):
	override Name as string:
		get:
			return 'task'
	
	def Run(_ as (string)):
		taskServ = cast(ITaskProvider, Context.Service['task'])
		taskServ.StartTask(Test, null)
	
	def Test(_ as (object)):
		for i in range(10):
			print 'Test'
			for j in range(5000000):
				pass
