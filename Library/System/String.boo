namespace System

public class String:
	_Length as int
	Val as (char)
	
	Chars[idx as int] as char:
		get:
			return Val[idx]
	
	Length as int:
		get:
			return _Length
	
	def constructor(chs as (char)):
		_Length = chs.Length
		Val = chs
