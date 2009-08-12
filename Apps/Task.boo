namespace Renraku.Apps

import Renraku.Kernel

class Task(Application):
	override Name as string:
		get:
			return 'task'
	
	Val as int
	def Run(_ as (string)):
		taskServ = cast(ITaskProvider, Context.Service['task'])
		Val = 0xCAFEBABE
		taskServ.StartTask(Test, null)
	
	def Test(_ as (object)):
		for i in range(10):
			printhex Val++
			for j in range(5000000):
				pass
