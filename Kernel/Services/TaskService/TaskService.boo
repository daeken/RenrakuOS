namespace Renraku.Kernel

import System.Collections
import Renraku.Core.Memory

callable TaskCallable(args as (object)) as void

public class Task:
	PC as uint
	Registers as Pointer [of uint]
	
	def constructor(stackSize as int, taskFunc as TaskCallable, args as (object)):
		Registers = Pointer [of uint](MemoryManager.Allocate(4*8))
		
		argCount = args.Length
		newStack as uint = MemoryManager.Allocate(stackSize) + stackSize - 4*argCount
		
		taskObj = Pointer [of uint](Pointer [of uint].GetAddr(taskFunc))
		if taskObj[0] != 0: # Task is an instance method
			newStack -= 4
		
		stackPtr = Pointer [of uint](newStack)
		i = argCount
		while i-- != 0:
			stackPtr[i] = Pointer [of object].GetAddr(args[i])
		
		if taskObj[0] != 0:
			stackPtr[argCount] = taskObj[0]
		
		PC = taskObj[1]
		Registers[5] = newStack

public interface ITaskProvider:
	def StartTask(taskFunc as TaskCallable, args as (object)):
		pass

public class TaskService(IService):
	override ServiceId:
		get:
			return 'task'
	
	Tasks as ArrayList
	def constructor():
		Tasks = ArrayList(16)
		
		Context.Register(self)
		print 'Task service initialized.'
	
	def StartTask(taskFunc as TaskCallable, args as (object)):
		taskFunc(args)
		#Tasks.Add(Task(4*1024*1024, taskFunc, args))
