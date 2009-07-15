namespace System

public class String:
	_Length as int
	Val as (byte)
	
	Chars[idx as int] as char:
		get:
			return cast(char, Val[idx])
	
	Length as int:
		get:
			return _Length
