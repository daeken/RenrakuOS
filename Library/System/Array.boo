namespace System

public class Array:
	_Length as int
	
	Length:
		get:
			return _Length
	
	static def Copy(src as (object), dest as (object), count as int):
		i = 0
		while i < count:
			dest[i] = src[i]
			++i
