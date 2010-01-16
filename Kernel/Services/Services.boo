namespace Renraku.Kernel

public static class Services:
	public def Register():
		print 'Services registered.'
		
		PlatformServices.Register()
