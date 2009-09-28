namespace Renraku.Apps

import Renraku.Kernel
import System

public class SetEnv(Application):
	override Name as string:
		get:
			return 'setenv'
	
	override HelpString as string:
		get:
			return 'setenv\t\tView environment variables.\nsetenv <variable> <value>\tChange an environment variable.'

	def Run(args as (string)):
		if args.Length == 3:
			Context.SetVar(args[1], args[2])
		elif args.Length == 1:
			i = 0
			environ = Context.Environ
			while i < environ.Count:
				env = cast(EnvVariable, environ[i++])
				Console.Write(env.Key)
				Console.Write('="')
				Console.Write(env.Value)
				Console.WriteLine('"')
		else:
			print 'Invalid number of arguments.'
	
