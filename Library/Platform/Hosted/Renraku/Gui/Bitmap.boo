namespace Renraku.Gui

import System.Drawing

public class Bitmap(IWidget):
	public Width as int
	public Height as int
	public Pixels as (Color, 2)
	
	static def FromFile(fn as string):
		bitmap = System.Drawing.Bitmap(System.Drawing.Image.FromFile(fn))
		
		pixels = matrix(Color, bitmap.Width, bitmap.Height)
		for y in range(bitmap.Height):
			for x in range(bitmap.Width):
				color = bitmap.GetPixel(x, y)
				if color.A == 255:
					pixels[x, y] = color
				else:
					ratio = color.A / 255.0
					inv = 255 * (1.0 - ratio)
					pixels[x, y] = Color.FromArgb(
							cast(int, (color.R * ratio) + inv) % 256, 
							cast(int, (color.G * ratio) + inv) % 256, 
							cast(int, (color.B * ratio) + inv) % 256
						)
		return Bitmap(bitmap.Width, bitmap.Height, pixels)
	
	def constructor(width as int, height as int):
		Width = width
		Height = height
		Pixels = matrix(Color, width, height)
		
		for x in range(width):
			for y in range(height):
				Pixels[x, y] = Color.Transparent
	
	def constructor(width as int, height as int, color as Color):
		Width = width
		Height = height
		Pixels = matrix(Color, width, height)
		for x in range(width):
			for y in range(height):
				Pixels[x, y] = color
	
	def constructor(width as int, height as int, pixels as (Color, 2)):
		Width = width
		Height = height
		Pixels = pixels
	
	def Blit(x as int, y as int, bitmap as Bitmap):
		offX = offY = 0
		startX = x
		startY = y
		if x < 0:
			offX = -x
		if y < 0:
			offY = -y
		
		width = bitmap.Width - offX
		if startX + width >= Width:
			width = Width - startX
		height = bitmap.Height - offY
		if startY + height >= Height:
			height = Height - startY
		
		for y in range(height):
			for x in range(width):
				color = bitmap.Pixels[x+offX, y+offY]
				if color.A != 0:
					Pixels[x+startX, y+startY] = color
	
	def Render() as Bitmap:
		return self
