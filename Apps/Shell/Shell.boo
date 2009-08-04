namespace Renraku.Apps

import System

public class Shell(Application):
	override Name as string:
		get:
			return 'shell'
	
	def Run(_ as (string)):
		Apps = (
				Draw(), 
				Echo(), 
				Exclaim(), 
				Reverse(), 
				PciDump(), 
				Shell(), 
			)
		
		print 'Welcome to Renrakushell'
		
		while true:
			Console.Write('R> ')
			line as string = Console.ReadLine()
			
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
