namespace Renraku.Kernel

import System.Collections
import Renraku.Core.Memory

callable DoneCallable(_ as object) as void
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
		
		newStack as uint = MemoryManager.Allocate(stackSize) + stackSize - 16
		stackPtr = Pointer [of uint](newStack)
		
		taskObj = Pointer [of uint](Pointer [of uint].GetAddr(taskFunc))
		PC = taskObj[1]

		doneObj = Pointer [of uint](Pointer [of uint].GetAddr(DoneCallable(Done)))
		stackPtr[0] = doneObj[1]
		stackPtr[1] = Pointer [of uint].GetAddr(args)
		stackPtr[2] = taskObj[0]
		stackPtr[3] = doneObj[0]
		
		Registers[0] = Pointer [of uint].GetAddr(Context.CurrentContext)
		Registers[3] = newStack - 12
		
		New = true
		Finished = false
	
	def Done(_ as object):
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
			if ++TaskId >= Tasks.Count:
				TaskId = 0
			
			if cast(Task, Tasks[TaskId]).Finished:
				Tasks.RemoveAt(TaskId)
			else:
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
