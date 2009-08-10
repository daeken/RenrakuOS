namespace Renraku.Kernel

import System.Collections
import Renraku.Core.Memory

callable DoneCallable() as void
callable TaskCallable(args as (object)) as void

public class Task:
	public PC as uint
	public Registers as Pointer [of uint]
	
	public New as bool
	public Finished as bool
	
	def constructor():
		Registers = Pointer [of uint](MemoryManager.Allocate(4*8))
		Finished = false
	
	def constructor(stackSize as int, taskFunc as TaskCallable, args as (object)):
		Registers = Pointer [of uint](MemoryManager.Allocate(4*8))
		
		if cast(object, args) == null:
			argCount = 0
		else:
			argCount = args.Length
		newStack as uint = MemoryManager.Allocate(stackSize) + stackSize - 4*argCount - 8
		
		taskObj = Pointer [of uint](Pointer [of uint].GetAddr(taskFunc))
		if taskObj[0] != 0: # Task is an instance method
			newStack -= 4
		
		stackPtr = Pointer [of uint](newStack)
		i = argCount
		while i-- != 0:
			stackPtr[i] = Pointer [of object].GetAddr(args[i])
		
		if taskObj[0] != 0:
			stackPtr[argCount] = taskObj[0]
			argCount++
		
		doneAddr = Pointer [of uint].GetAddr(DoneCallable(Done))
		doneObj = Pointer [of uint](doneAddr)
		stackPtr[argCount+1] = doneObj[0] # This task instance
		stackPtr[argCount] = doneObj[1] # Pointer to Task.Done
		
		PC = taskObj[1]
		Registers[0] = Pointer [of uint].GetAddr(Context.CurrentContext)
		Registers[3] = newStack - 12
		
		New = true
		Finished = false
	
	def Done():
		Finished = true
		while true:
			pass

public interface ITaskProvider:
	def StartTask(taskFunc as TaskCallable, args as (object)):
		pass

public class TaskService(IInterruptHandler, IService):
	override ServiceId:
		get:
			return 'task'
	
	override InterruptNumber:
		get:
			return 32
	
	Tasks as ArrayList
	CurrentTask as Task
	TaskId as int
	
	def constructor():
		Tasks = ArrayList(16)
		
		CurrentTask = Task()
		Tasks.Add(CurrentTask)
		TaskId = 0
		
		InterruptManager.AddHandler(self)
		Context.Register(self)
		print 'Task service initialized.'
	
	def StartTask(taskFunc as TaskCallable, args as (object)):
		Tasks.Add(Task(4*1024*1024, taskFunc, args))
	
	def Handle(regs as Pointer [of uint]):
		for i in range(8):
			CurrentTask.Registers[i] = regs[i]
		CurrentTask.PC = regs[8]
		
		oldId = TaskId
		oldTask = CurrentTask
		while true:
			if ++TaskId == Tasks.Count:
				TaskId = 0
			
			if not cast(Task, Tasks[TaskId]).Finished:
				CurrentTask = cast(Task, Tasks[TaskId])
				break
		
		if TaskId == oldId:
			return
		
		regs[3] = CurrentTask.Registers[3]
		stack = Pointer [of uint](regs[3]-8*4)
		stack[8] = CurrentTask.PC
		for i in range(8):
			stack[i] = CurrentTask.Registers[i]
		
		if CurrentTask.New:
			oldStack = Pointer [of uint](oldTask.Registers[3])
			stack[8+1] = oldStack[1]
			stack[8+2] = oldStack[2]
			CurrentTask.New = false
