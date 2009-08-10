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
		print 'Task!'
