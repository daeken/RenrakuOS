namespace Renraku.Apps

class Application:
	virtual Name as string:
		get:
			return null
	
	virtual def Run(args as (string)):
		pass
