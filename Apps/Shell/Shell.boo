namespace Renraku.Apps

import System

public class Shell:
	def constructor():
		print 'Welcome to Renrakushell'
		
		while true:
			Console.Write('R> ')
			line as string = null
			while true:
				ch = cast(char, Console.Read())
				if ch != 0:
					Console.WriteChar(ch)
					if ch == char('\n'):
						break
					if line == null:
						line = string((ch, ))
					else:
						line = string.Concat((line, string((ch, ))))
			print 'You typed:'
			print line
