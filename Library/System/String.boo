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
	
	static def Concat(strs as (String)):
		size = 0
		i = 0
		while i < strs.Length:
			size += strs[i].Length
			++i
		
		newarr = array(char, size)
		
		off = 0
		i = 0
		while i < strs.Length:
			j = 0
			while j < strs[i].Length:
				newarr[off] = strs[i].Val[j]
				++j
				++off
			++i
		
		return String(newarr)
	
	static def op_Equality(left as uint, right as uint):
		return left == right
