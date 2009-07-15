namespace Renraku.Apps

import System

class Echo(Application):
	override Name as string:
		get:
			return 'echo'
	
	def Run(_ as (string)):
		print 'Renraku echo terminal'
		
		while true:
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
			
			if line == 'exit':
				break
			
			print line
