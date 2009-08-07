namespace Renraku.Compiler

import System.IO

class LogoIntrinsics(ClassIntrinsic):
	def constructor():
		HasCtor = false
		Register('Renraku.Apps::Logo')
		RegisterCall('get_Pixels', GetPixels)
		RegisterCall('get_Palette', GetPalette)
	
	def GetPixels() as duck:
		yield ['pop']
		pixels = []
		file = File.OpenRead('Apps/LogoPixels.txt')
		sr = StreamReader(file)
		data = sr.ReadToEnd()
		for pixel in data.Split((char(','), ), 320*114+1):
			pixel = pixel.Trim()
			if pixel.Length == 0:
				continue
			pixels.Add(int.Parse(pixel))
		
		yield ['pushbytes', pixels]
	
	def GetPalette() as duck:
		yield ['pop']
		pixels = []
		file = File.OpenRead('Apps/LogoPalette.txt')
		sr = StreamReader(file)
		data = sr.ReadToEnd()
		for pixel in data.Split((char(','), ), 769):
			pixel = pixel.Trim()
			if pixel.Length == 0:
				continue
			pixels.Add(int.Parse(pixel))
		
		yield ['pushbytes', pixels]
