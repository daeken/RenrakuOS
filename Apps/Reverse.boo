namespace Renraku.Apps

import System

class Reverse(Application):
	override Name as string:
		get:
			return 'reverse'
	
	def Run(args as (string)):
		off = args.Length - 1
		
		while off > 0:
			chars = array(char, args[off].Length)
			
			i = 0
			while i < args[off].Length:
				chars[i] = args[off][args[off].Length - i - 1]
				++i
			
			Console.Write(string(chars))
			Console.WriteChar(char(' '))
			
			--off
		
		print ' '
