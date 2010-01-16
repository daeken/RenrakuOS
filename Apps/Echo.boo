namespace Renraku.Apps

import System

class Echo(Application):
	override Name as string:
		get:
			return 'echo'
	
	override HelpString as string:
		get:
			return 'Echo terminal.'
	
	def Run(_ as (string)):
		print 'Renraku echo terminal'
		
		while true:
			line as string = null
			while true:
				ch = cast(char, Console.Read())
				if ch != 0:
					#Console.Write(ch)
					if ch == char('\n'):
						break
					elif ch == char('\r'):
						continue
					elif line == null:
						line = string((ch, ))
					else:
						line = string.Concat(line, string((ch, )))
			
			if line == 'exit':
				break
			
			print line
