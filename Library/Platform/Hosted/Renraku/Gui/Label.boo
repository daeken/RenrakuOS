namespace Renraku.Gui

import System.Drawing
import System.IO

class Font:
	public Size as (int)
	public Chars as ((byte))
	
	def constructor(fn as string):
		fp = File.OpenRead(fn)
		br = BinaryReader(fp)
		Size = (cast(int, br.ReadByte()), cast(int, br.ReadByte()))
		
		Chars = array [of (byte)](256)
		for i in range(256):
			Chars[i] = br.ReadBytes(Size[0]*Size[1])
		
		br.Close()

public class Label(IWidget):
	static DefaultFont as Font = null
	
	_Text as string
	public Text as string:
		get:
			return _Text
		set:
			if _Text != value:
				_Text = value
				Update()
	
	_FgColor as Color
	public FgColor as Color:
		get:
			return _FgColor
		set:
			_FgColor = value
			Update()
	_BgColor as Color
	public BgColor as Color:
		get:
			return _BgColor
		set:
			_BgColor = value
			Update()
	
	CachedBitmap as Bitmap = null
	
	def constructor():
		self('')
	
	def constructor(text as string):
		_Text = text
		_FgColor = Color.Black
		_BgColor = Color.Transparent
		Update()
	
	def Render() as Bitmap:
		return CachedBitmap
	
	def Update():
		if _Text == '':
			return
		
		if DefaultFont == null:
			DefaultFont = Font('Images/Dina.fbin')
		
		lines = _Text.Split(char('\n'))
		width = 0
		for line in lines:
			if line.Length > width:
				width = line.Length
		
		CachedBitmap = Bitmap(DefaultFont.Size[0] * width, DefaultFont.Size[1] * lines.Length, _BgColor)
		
		offY = 0
		for line in lines:
			offX = 0
			for ch in line:
				ich = cast(int, ch)
				if ich > 0xFF:
					offX += DefaultFont.Size[0]
					continue
				
				bitmap = DefaultFont.Chars[ich]
				
				i = 0
				for y in range(DefaultFont.Size[1]):
					row = (offY + y) * CachedBitmap.Width + offX
					for x in range(DefaultFont.Size[0]):
						if bitmap[i++] == 1:
							CachedBitmap.Pixels[row++] = _FgColor
						else:
							CachedBitmap.Pixels[row++] = _BgColor
				offX += DefaultFont.Size[0]
			offY += DefaultFont.Size[1]
