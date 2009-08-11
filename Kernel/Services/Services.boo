namespace Renraku.Kernel

public static class Services:
	public def Register():
		TaskService()
		KeyboardService().Keymap = USEnglish()
		MouseService()
		
		PciService()
		NetworkService()
		VgaService()
		GuiService()
		
		print 'Services registered.'
