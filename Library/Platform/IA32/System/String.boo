namespace System

import Renraku.Core.Memory

public class String:
	_Length as int
	Val as (char)
	
	self[idx as int] as char:
		get:
			return Val[idx]
	
	Chars[idx as int] as char:
		get:
			return Val[idx]
	
	Length as int:
		get:
			return _Length
	
	def constructor(chs as (char)):
		_Length = chs.Length
		Val = chs
	
	static def Concat(obj as object):
		strs = cast((String), obj)
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
	
	def Split(glue as (char), opt as StringSplitOptions) as (String):
		if glue.Length != 1 or opt != StringSplitOptions.RemoveEmptyEntries:
			return null
		gluechar = glue[0]
		
		count = 1
		i = 0
		while i < Length:
			if i != 0 and Val[i] == gluechar:
				while Val[i++] == gluechar:
					pass
				--i
				count++
			++i
		
		ret = array(String, count)
		
		i = 0
		idx = 0
		while idx < count:
			size = 0
			while i < Length and Val[i] != gluechar:
				++size
				++i
			i -= size
			
			arr = array(char, size)
			j = 0
			while size > 0:
				arr[j++] = Val[i]
				--size
				++i
			ret[idx] = String(arr)
			
			while Val[i++] == gluechar:
				pass
			--i
			
			++idx
		
		return ret
	
	#def Substring(start as int):
	#	length = _Length - start
	#	return Substring(start, length)

	def Substring(start as int, length as int):
		ret = array(char, length)
		idx = 0
		while idx < length:
			ret[idx] = Val[start+idx]
			++idx
		return String(ret)

	static def op_Equality(lstr as String, rstr as String):
		left = Pointer [of string].GetAddr(lstr)
		right = Pointer [of string].GetAddr(rstr)
		if left == right:
			return true
		elif left == 0 or right == 0:
			return false
		
		if lstr.Length != rstr.Length:
			return false
		
		i = 0
		while i < lstr.Length:
			if lstr[i] != rstr[i]:
				return false
			++i
		return true
