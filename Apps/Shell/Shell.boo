namespace Renraku.Apps

import System

public class Shell(Application):
	override Name as string:
		get:
			return 'shell'
	
	def Run(_ as (string)):
		Apps = (
				Echo(), 
				HalStatus(), 
				Reverse(), 
				PciDump(), 
				Shell(), 
			)
		
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
			
			if line == 'exit':
				break
			
			args = line.Split((char(' '), ), StringSplitOptions.RemoveEmptyEntries)
			
			i = 0
			app as Application = null
			while i < Apps.Length:
				if Apps[i].Name == args[0]:
					app = Apps[i]
					break
				++i
			
			if app == null:
				print 'Unknown command'
			else:
				app.Run(args)
