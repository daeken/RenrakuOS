namespace System.Text

import System

class StringBuilder:
	_Length as int
	buffer as (char)
	capacity as int
	grow as int

	def constructor():
		grow = 512
		capacity = grow
		_Length = 0
		buffer = array(char, capacity)

	def _copy(frm as (char), src as int,
			  to as (char), dest as int,
			  length as int):
		i = 0
		while i < length:
			ch = frm[src+i]
			to[dest+i] = frm[src+i]
			++i

	def Append(chs as (char)):
		total = _Length + chs.Length
		EnsureCapacity(total)
		_copy(chs, 0, buffer, _Length, chs.Length)
		_Length = total
		return self

	def EnsureCapacity(cap as int):
		if capacity >= cap:
			return

		while capacity < cap:
			capacity += grow
		new_buf = array(char, capacity)
		
		_copy(buffer, 0, new_buf, 0, _Length)
		buffer = new_buf
		
		return capacity
	
	def Remove(start as int, length as int):
		rest = _Length - start - length
		_copy(buffer, start+length, buffer, start, rest)
		_Length -= length
		return self

	def ToString() as string:
		str_buf = array(char, _Length)
		_copy(buffer, 0, str_buf, 0, _Length)
		return string(str_buf)
