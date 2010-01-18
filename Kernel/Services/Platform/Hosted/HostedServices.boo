namespace Renraku.Kernel

public static class PlatformServices:
	public def Register():
		TaskService()
		SdlMouseService()
		SdlKeyboardService()
		SdlVideoService()
		GuiService()
		
		print 'Platform services registered.'
