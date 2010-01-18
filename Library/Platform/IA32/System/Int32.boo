namespace System

static class Int32:
	def Parse(str as string) as int:
		ret = 0
		i = 0
		while i < str.Length:
			ret *= 10
			ret += cast(int, str[i]) - 48 # '0'
			++i
		
		return ret
