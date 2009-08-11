namespace System.Collections

import System

public class ArrayList:
	Values as (object)
	Index as int
	
	Count as int:
		get:
			return Index
	
	self [idx as int] as object:
		get:
			return Values[idx]
		set:
			Values[idx] = value
	
	def constructor():
		self(4)
	
	def constructor(capacity as int):
		Values = array(object, capacity)
		Index = 0
	
	def Add(value as object):
		if Index == Values.Length:
			newvals = array(object, Values.Length+4)
			Array.Copy(Values, 0, newvals, 0, Values.Length)
			Values = newvals
		
		Values[Index++] = value
	
	def RemoveAt(index as int):
		if index == Index-1: # Element's at the end, don't copy
			pass
		else:
			Array.Copy(Values, index+1, Values, index, Values.Length-index-1)
		
		Index--
