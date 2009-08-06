namespace System.Collections

import System

public class ArrayList:
	Values as (object)
	Index as int
	
	Length as int:
		get:
			return Index
	
	def constructor(capacity as int):
		Values = array(object, capacity)
		Index = 0
	
	def Add(value as object):
		if Index == Values.Length:
			newvals = array(object, Values.Length+4)
			Array.Copy(Values, 0, newvals, 0, Values.Length)
			Values = newvals
		
		Values[Index++] = value
	
	self [idx as int] as object:
		get:
			return Values[idx]
		set:
			Values[idx] = value
