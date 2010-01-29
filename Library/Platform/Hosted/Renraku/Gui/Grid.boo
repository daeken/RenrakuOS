namespace Renraku.Gui

import System.Collections.Generic

class Pair [of T1, T2]:
	public V1 as T1
	public V2 as T2
	
	def constructor(v1 as T1, v2 as T2):
		V1 = v1
		V2 = v2

class Grid(IWidget):
	public Children as List [of List [of IWidget]]
	
	def constructor():
		self(null)
	
	def constructor(func as callable(Grid)):
		Children = List [of List [of IWidget]]()
		
		if func != null:
			func(self)
	
	public def Add(column as int, row as int, widget as IWidget):
		if Children.Count <= row:
			for i in range(row - Children.Count):
				Children.Add(null)
			Children.Add(List [of IWidget]())
		
		rowList = Children[row]
		if rowList == null:
			Children[row] = rowList = List [of IWidget]()
		if rowList.Count <= column:
			for i in range(column - rowList.Count + 1):
				rowList.Add(null)
		rowList[column] = widget
	
	def Render() as Bitmap:
		grid = List [of List [of Pair [of IWidget, Bitmap]]]()
		
		columnCount = 0
		for row in Children:
			if row == null:
				continue
			
			gridRow = List [of Pair [of IWidget, Bitmap]]()
			grid.Add(gridRow)
			
			count = row.Count
			if count > columnCount:
				columnCount = count
			for column in row:
				if column == null:
					gridRow.Add(null)
				else:
					gridRow.Add(Pair [of IWidget, Bitmap](column, column.Render()))
		
		rowHeights = array [of int](grid.Count)
		columnWidths = array [of int](columnCount)
		i = 0
		for row in grid:
			height = 0
			j = 0
			for pair in row:
				if pair == null:
					++j
					continue
				elemHeight = pair.V2.Height
				if elemHeight > height:
					height = elemHeight
				elemWidth = pair.V2.Width
				if elemWidth > columnWidths[j]:
					columnWidths[j] = elemWidth
				++j
			rowHeights[i++] = height
		
		def sum(arr as (int)):
			value = 0
			for sub in arr:
				value += sub
			return value
		
		bitmap = Bitmap(sum(columnWidths), sum(rowHeights))
		
		y = 0
		i = 0
		for row in grid:
			if row == null:
				++i
				continue
			
			x = 0
			j = 0
			for pair in row:
				if pair != null:
					widget = pair.V1
					wbitmap = pair.V2
					widget.Position = (x, y)
					
					if widget.Expandable and (wbitmap.Width < columnWidths[j] or wbitmap.Height < rowHeights[i]):
						wbitmap = widget.Render(columnWidths[j], rowHeights[i])
					widget.Size = (wbitmap.Width, wbitmap.Height)
					bitmap.Blit(x, y, wbitmap)
				x += columnWidths[j++]
			y += rowHeights[i++]
		
		return bitmap
