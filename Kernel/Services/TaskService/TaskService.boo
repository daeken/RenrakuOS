namespace Renraku.Kernel

import System.Collections
import Renraku.Core.Memory

public class Task:
	PC as uint
	Registers as Pointer [of uint]
	
	def constructor(stackSize as int, taskFunc as object, args as (object)):
		Registers = Pointer [of uint](MemoryManager.Allocate(4*8))
		
		argCount = args.Length
		newStack as uint = MemoryManager.Allocate(stackSize) + stackSize - 4*argCount
		stackPtr = Pointer [of uint](newStack)
		i = argCount
		while i-- != 0:
			stackPtr[i] = Pointer [of object].GetAddr(args[i])
		
		Registers[5] = newStack

public interface ITaskProvider:
	def StartTask(taskFunc as object, args as (object)):
		pass

public class TaskService(IService):
	override ServiceId:
		get:
			return 'task'
	
	Tasks as ArrayList
	def constructor():
		Tasks = ArrayList(16)
	
	def StartTask(taskFunc as object, args as (object)):
		Tasks.Add(Task(4*1024*1024, taskFunc, args))
