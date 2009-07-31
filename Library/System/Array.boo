namespace System

public class Array:
	_Length as int
	
	static def Copy(frm as (char), src as int,
					to as (char), dest as int,
					length as int):
		i = 0
		while i < length:
			to[dest+i] = frm[src+i]
			++i
	
	Length:
		get:
			return _Length
	
	static def Copy(src as (object), dest as (object), count as int):
		i = 0
		while i < count:
			dest[i] = src[i]
			++i
