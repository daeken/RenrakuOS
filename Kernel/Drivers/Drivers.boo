namespace Renraku.Kernel

static class Drivers:
	def Load():
		Timer()
		Keyboard().Keymap = USEnglish()
		Pci()
		PcNet()
		
		print 'Drivers loaded.'
