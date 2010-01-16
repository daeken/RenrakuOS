namespace Renraku.Kernel

public static class PlatformServices:
	public def Register():
		TaskService()
		KeyboardService().Keymap = USEnglish()
		MouseService()
		
		PciService()
		NetworkService()
		VgaService()
		GuiService()
		
		print 'Platform services registered.'
