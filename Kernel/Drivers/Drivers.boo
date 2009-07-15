namespace Renraku.Kernel

static class Drivers:
	def Load():
		Timer()
		Keyboard().Keymap = USEnglish()
		
		print 'Drivers loaded.'
