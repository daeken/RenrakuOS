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
		
		CachedBitmap = Bitmap(DefaultFont.Size[0] * Text.Length, DefaultFont.Size[1], _BgColor)
		
		off = 0
		for ch in _Text:
			ich = cast(int, ch)
			if ich > 0xFF:
				off += DefaultFont.Size[0]
				continue
			
			bitmap = DefaultFont.Chars[ich]
			
			i = 0
			for y in range(DefaultFont.Size[1]):
				row = y * CachedBitmap.Width + off
				for x in range(DefaultFont.Size[0]):
					if bitmap[i++] == 1:
						CachedBitmap.Pixels[row++] = _FgColor
					else:
						CachedBitmap.Pixels[row++] = _BgColor
			off += DefaultFont.Size[0]
