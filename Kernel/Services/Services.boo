namespace Renraku.Kernel

public static class Services:
	public def Register():
		KeyboardService().Keymap = USEnglish()
		TimerService()
		PciService()
		VgaService()
		GuiService()
		
		print 'Services registered.'
