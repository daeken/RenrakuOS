namespace System.Collections

import System

class Queue:
	private static final DEFAULT_CAP = 256
	private buffer as (char)
	private front = 0
	private back = 0
	
	Length:
		get:
			if front <= back:
				return back - front
			else:
				return back + (buffer.Length - front)
	
	def constructor():
		buffer = array(char, DEFAULT_CAP)
		
	def Enqueue(c as char):
		EnsureRoom(1)
		
		if back == buffer.Length:
			back = 0
		
		buffer[back] = c
		++back
		
	def Dequeue() as char:
		if front == back:
			# XXX: Error out somehow?
			return cast(char, 20)
		else:
			c = Peek()
			++front
			if front == buffer.Length:
				front = 0
			return c
	
	def Peek() as char:
		return buffer[front]
	
	private def IncreaseSize(wanted_size as int):
		new_length = 0
		while new_length < wanted_size:
			new_length = buffer.Length*2
		new_buffer = array(char, new_length)
		
		orig_len = Length
		# We haven't wrapped, so we can just copy everything at once
		if front < back:
			Array.CopyChars(buffer, front, new_buffer, 0, orig_len)
		# Wrapping has been done, copy in two steps
		else:
			front_len = buffer.Length - front
			back_len = back
			Array.CopyChars(buffer, front, new_buffer, 0, front_len)
			Array.CopyChars(buffer, 0, new_buffer, front, back_len)
		
		front = 0
		back = orig_len
		buffer = new_buffer
	
	private def EnsureRoom(amount as int):
		new_len = Length + amount
		
		# Only bother growing the buffer if there is no more room
		if new_len > buffer.Length:
			IncreaseSize(new_len)
