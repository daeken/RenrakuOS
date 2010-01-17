namespace Renraku.Kernel

import System.Threading

callable TaskCallable(*args) as void

public interface ITaskProvider:
	def StartTask(taskFunc as TaskCallable, *args):
		pass

public class TaskService(IService, ITaskProvider):
	override ServiceId:
		get:
			return 'task'
	
	def constructor():
		Context.Register(self)
		print 'Task service initialized.'
	
	def StartTask(taskFunc as TaskCallable, *args):
		context = Context.CurrentContext
		thread = Thread() do:
			Context.CurrentContext = context
			taskFunc(*args)
		thread.Start()
