namespace Renraku.Kernel

public static class Services:
	public def Register():
		KeyboardService().Keymap = USEnglish()
		MouseService()
		TaskService()
		PciService()
		VgaService()
		GuiService()
		
		print 'Services registered.'
