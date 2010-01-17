namespace Renraku.Kernel

public static class PlatformServices:
	public def Register():
		TaskService()
		SdlVideoService()
		
		print 'Platform services registered.'
