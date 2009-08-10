namespace Renraku.Kernel

public static class Services:
	public def Register():
		KeyboardService().Keymap = USEnglish()
		MouseService()
		TaskService()
		TimerService()
		PciService()
		VgaService()
		
		print 'Services registered.'
