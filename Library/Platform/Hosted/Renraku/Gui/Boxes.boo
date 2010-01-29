namespace Renraku.Gui

import System.Collections.Generic

abstract class Box(IWidget):
	public Children as List [of IWidget]
	
	def constructor():
		Children = List [of IWidget]()
	
	def Add(widget as IWidget) as IWidget:
		Children.Add(widget)
		return widget
	
	def Remove(widget as IWidget):
		Children.Remove(widget)
	
	def Clicked(x as int, y as int, down as bool, button as int):
		for child in Children:
			if child.Inside(x, y):
				child.Clicked(x - child.Position[0], y - child.Position[1], down, button)
				break

class VBox(Box):
	def Render() as Bitmap:
		rendered = List [of Bitmap]()
		height = 0
		width = 0
		for child in Children:
			child.Position = (0, height)
			bitmap = child.Render()
			if bitmap == null:
				continue
			child.Size = bitmap.Width, bitmap.Height
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
			child.Position = (width, 0)
			bitmap = child.Render()
			if bitmap == null:
				continue
			child.Size = bitmap.Width, bitmap.Height
			width += bitmap.Width
			if bitmap.Height > height:
				height = bitmap.Height
			rendered.Add(bitmap)
		
		bitmap = Bitmap(width, height)
		x = 0
		for child in rendered:
			bitmap.Blit(x, 0, child)
			x += child.Width
		return bitmap
