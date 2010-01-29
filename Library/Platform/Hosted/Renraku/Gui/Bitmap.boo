namespace Renraku.Gui

import System.Drawing

public class Bitmap(IWidget):
	public Width as int
	public Height as int
	public Pixels as (Color)
	
	static def FromFile(fn as string):
		bitmap = System.Drawing.Bitmap(System.Drawing.Image.FromFile(fn))
		
		pixels = array [of Color](bitmap.Height * bitmap.Width)
		i = 0
		for y in range(bitmap.Height):
			for x in range(bitmap.Width):
				pixels[i++] = bitmap.GetPixel(x, y)
		return Bitmap(bitmap.Width, bitmap.Height, pixels)
	
	def constructor(width as int, height as int):
		Width = width
		Height = height
		Pixels = array [of Color](height * width)
		
		i = 0
		for x in range(width):
			for y in range(height):
				Pixels[i++] = Color.Transparent
	
	def constructor(width as int, height as int, color as Color):
		Width = width
		Height = height
		Pixels = array [of Color](width * height)
		i = 0
		for x in range(width):
			for y in range(height):
				Pixels[i++] = color
	
	def constructor(width as int, height as int, pixels as (Color)):
		Width = width
		Height = height
		Pixels = pixels
	
	def Blit(x as int, y as int, bitmap as Bitmap):
		if x < 0:
			destX = 0
			srcX = -x
		else:
			destX = x
			srcX = 0
		if y < 0:
			destY = 0
			srcY = -y
		else:
			destY = y
			srcY = 0
		
		width = bitmap.Width
		if destX + width >= Width:
			width = Width - destX
		height = bitmap.Height
		if destY + height >= Height:
			height = Height - destY
		
		if width < 1 or height < 1:
			return
		
		for y in range(height):
			destOff = (y+destY) * Width + destX
			srcOff = (y+srcY) * bitmap.Width + srcX
			for x in range(width):
				color = bitmap.Pixels[srcOff++]
				if color.A == 255:
					Pixels[destOff++] = color
				elif color.A != 0:
					ratio = color.A / 255.0
					inv = 1.0 - ratio
					bottom = Pixels[destOff]
					Pixels[destOff++] = Color.FromArgb(
							cast(int, (color.R * ratio) + (bottom.R * inv)), 
							cast(int, (color.G * ratio) + (bottom.G * inv)), 
							cast(int, (color.B * ratio) + (bottom.B * inv))
						)
				else:
					destOff++
	
	def Render() as Bitmap:
		return self
