namespace Renraku.Kernel

interface IKeyboard(IDriver):
	def Read() as char:
		pass
