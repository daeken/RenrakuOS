namespace Renraku.Kernel

static class Drivers:
	def Load():
		Timer()
		Pci()
		PcNet()
		
		print 'Drivers loaded.'
