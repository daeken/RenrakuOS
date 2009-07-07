namespace Renraku.Compiler

class StringIntrinsics(ClassIntrinsic):
	def constructor():
		Register('System::String')
		RegisterCall('get_Chars', GetChars)
	
	def GetChars() as duck:
		yield ['pushelem', string]
