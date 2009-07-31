namespace System.Collections

import System

public class ArrayList:
	Values as (object)
	Index as int
	
	def constructor(capacity as int):
		Values = array(object, capacity)
		Index = 0
	
	def Add(value as object):
		if Index == Values.Length:
			newvals = array(object, Values.Length+4)
			Array.Copy(Values, newvals, Values.Length)
			Values = newvals
		
		Values[Index++] = value
