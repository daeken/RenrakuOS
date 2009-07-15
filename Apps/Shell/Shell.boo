namespace Renraku.Apps

import System

public class Shell:
	def constructor():
		print 'Welcome to Renrakushell'
		
		while true:
			Console.Write('R> ')
			while true:
				ch = Console.Read()
				if ch != 0:
					Console.WriteChar(cast(char, ch))
					if ch == char('\n'):
						break
