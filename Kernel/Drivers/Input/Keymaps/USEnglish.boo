namespace Renraku.Kernel

class USEnglish(IKeymap):
	Keymap as (int)
	def constructor():
		Keymap = (
				0, 27, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 45, 61, 8, 9, 113, 119, 101, 
				114, 116, 121, 117, 105, 111, 112, 91, 93, 10, 0, 97, 115, 100, 102, 103, 
				104, 106, 107, 108, 59, 39, 96, 0, 92, 122, 120, 99, 118, 98, 110, 109, 44, 
				46, 47, 0, 42, 0, 32, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 45, 0, 
				0, 0, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			)
		
		print 'US English keymap initialized.'
	
	def Map(ch as int) as int:
		return Keymap[ch]
