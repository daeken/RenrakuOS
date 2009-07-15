namespace Renraku.Kernel

static class Drivers:
	def Load():
		Timer()
		Keyboard()
		
		print 'Drivers loaded.'
