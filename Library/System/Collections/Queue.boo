namespace System.Collections

import System

class Queue:
	private static final DEFAULT_CAP = 256
	private buffer as (object)
	private front = 0
	private back = 0
	
	Count:
		get:
			if front <= back:
				return back - front
			else:
				return back + (buffer.Length - front)
	
	def constructor():
		buffer = array(object, DEFAULT_CAP)
		
	def Enqueue(obj as object):
		EnsureRoom(1)
		
		if back == buffer.Length:
			back = 0
		
		buffer[back] = obj
		++back
		
	def Dequeue() as object:
		if front == back:
			# XXX: Error out somehow?
			return null
		else:
			obj = Peek()
			++front
			if front == buffer.Length:
				front = 0
			return obj
	
	def Peek() as object:
		return buffer[front]
	
	private def IncreaseSize(wanted_size as int):
		new_length = 0
		while new_length < wanted_size:
			new_length = buffer.Length*2
		new_buffer = array(object, new_length)
		
		orig_len = Count
		# We haven't wrapped, so we can just copy everything at once
		if front < back:
			Array.Copy(buffer, front, new_buffer, 0, orig_len)
		# Wrapping has been done, copy in two steps
		else:
			front_len = buffer.Length - front
			back_len = back
			Array.Copy(buffer, front, new_buffer, 0, front_len)
			Array.Copy(buffer, 0, new_buffer, front, back_len)
		
		front = 0
		back = orig_len
		buffer = new_buffer
	
	private def EnsureRoom(amount as int):
		new_len = Count + amount
		
		# Only bother growing the buffer if there is no more room
		if new_len > buffer.Length:
			IncreaseSize(new_len)
