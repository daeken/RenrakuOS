namespace Renraku.Gui

import System.Collections.Generic

abstract class Box(IWidget):
	public Children as List [of IWidget]
	
	def constructor():
		Children = List [of IWidget]()
	
	def Add(widget as IWidget) as IWidget:
		Children.Add(widget)
		return widget

class VBox(Box):
	def Render() as Bitmap:
		rendered = List [of Bitmap]()
		height = 0
		width = 0
		for child in Children:
			bitmap = child.Render()
			if bitmap == null:
				continue
			height += bitmap.Height
			if bitmap.Width > width:
				width = bitmap.Width
			rendered.Add(bitmap)
		
		bitmap = Bitmap(width, height)
		y = 0
		for child in rendered:
			bitmap.Blit(0, y, child)
			y += child.Height
		return bitmap

class HBox(Box):
	def Render() as Bitmap:
		rendered = List [of Bitmap]()
		height = 0
		width = 0
		for child in Children:
			bitmap = child.Render()
			if bitmap == null:
				continue
			width += bitmap.Height
			if bitmap.Height > height:
				height = bitmap.Height
			rendered.Add(bitmap)
		
		bitmap = Bitmap(width, height)
		x = 0
		for child in rendered:
			bitmap.Blit(x, 0, child)
			x += child.Width
		return bitmap
