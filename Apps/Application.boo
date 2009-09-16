namespace Renraku.Apps

class Application:
	virtual Name as string:
		get:
			return null
	
	virtual HelpString as string:
		get:
			return 'No help string.'

	virtual def Run(args as (string)):
		pass
