namespace System

public class Array:
	_Length as int
	
	Length:
		get:
			return _Length
	
	static def Copy(frm as (char), src as int,
					to as (char), dest as int,
					length as int):
		i = 0
		while i < length:
			to[dest+i] = frm[src+i]
			++i
	
	static def Copy(frm as (object), src as int,
					to as (object), dest as int,
					length as int):
		i = 0
		while i < length:
			to[dest+i] = frm[src+i]
			++i
