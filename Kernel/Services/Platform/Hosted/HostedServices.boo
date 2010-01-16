namespace Renraku.Kernel

public static class PlatformServices:
	public def Register():
		TaskService()
		
		print 'Platform services registered.'
