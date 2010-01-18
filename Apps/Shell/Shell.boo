namespace Renraku.Apps

import System
import System.Collections

public class Shell(Application):
    // Renraku Shell.
    // Implemented features:
    //      - Command list
    //      - Command/Capsule help text
    //      - Command history
    //  
    // Planned Features:

	override Name as string:
		get:
			return 'shell'
	
	override HelpString as string:
		get:
			return 'Renraku Shell.'

	def Run(_ as (string)):
		Apps = (
				#ArpTest(), 
				#DhcpApp(), 
				#Draw(), 
				Echo(), 
				#Exclaim(),
				GraphicalConsole(), 
				Gui(),  
				#Logo(), 
				#Mouse(), 
				#PciDump(), 
				Reverse(), 
				Shell(), 
				Task(), 
				SetEnv(),
				#Windows(),
				Video(), 
			)
		CommandHistory = ArrayList()
		
		print 'Welcome to Renraku Shell'
		print '-----------------------------'
		print ' '
		print 'Type `help` for command list.'
		print ' '
		
		toplevel = false
		if Renraku.Kernel.Context.GetVar('prompt') == null:
			Renraku.Kernel.Context.SetVar('prompt', 'R>')
			toplevel = true
		else:
			Renraku.Kernel.Context.Push()
		
		while true:
			Console.Write(Renraku.Kernel.Context.GetVar('prompt'))
			Console.Write(' ')
			line as string = Console.ReadLine()
			if line == '':
				continue
			CommandHistory.Add(line)
			
			if line == 'exit' and not toplevel:
				Renraku.Kernel.Context.Pop()
				break
			elif line == null:
				break
			
			args = line.Split((char(' '), ), StringSplitOptions.RemoveEmptyEntries)
			
			if args[0] == 'help':
				if args.Length > 1:
					if args[1] == 'history':
						print 'Type `history` for a list of previously entered commands.'
						print 'Type `history clear` to clear the history.'
					else:
						i = 0
						while i < Apps.Length:
							if Apps[i].Name == args[1]:
								Console.WriteLine(Apps[i].HelpString)
								break
							++i
				else:
					i = 0
					while i < Apps.Length:
						Console.WriteLine(Apps[i++].Name)
					print 'history'
					print 'help'

			elif args[0] == 'history':
				if args.Length == 2 and args[1] == 'clear':
					CommandHistory = ArrayList()
				else:
					i = 0
					while i < CommandHistory.Count:			
						System.Console.WriteLine(CommandHistory[i++])
	
			elif args[0] == 'shutdown':
				Environment.Exit(0)

			else:
				
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
