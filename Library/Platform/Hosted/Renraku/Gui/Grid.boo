namespace Renraku.Gui

import System.Collections.Generic

class Pair [of T1, T2]:
	public V1 as T1
	public V2 as T2
	
	def constructor(v1 as T1, v2 as T2):
		V1 = v1
		V2 = v2

class Grid(IWidget):
	public Children as Dictionary [of int, Dictionary [of int, IWidget]]
	
	def constructor():
		self(null)
	
	def constructor(func as callable(Grid)):
		Children = Dictionary [of int, Dictionary [of int, IWidget]]()
		
		if func != null:
			func(self)
	
	public def Add(column as int, row as int, widget as IWidget):
		if not Children.ContainsKey(row):
			Children.Add(row, Dictionary [of int, IWidget]())
		
		Children[row][column] = widget
	
	def Render() as Bitmap:
		grid = List [of List [of Pair [of IWidget, Bitmap]]]()
		
		columnCount = 0
		lastRow = -1
		for row in Children:
			gap = row.Key - lastRow - 1
			if gap > 0:
				for i in range(gap):
					grid.Add(null)
			lastRow = row.Key
			
			gridRow = List [of Pair [of IWidget, Bitmap]]()
			grid.Add(gridRow)
			
			if row.Value.Count > columnCount:
				columnCount = row.Value.Count
			
			lastColumn = -1
			for column in row.Value:
				gap = column.Key - lastColumn - 1
				if gap > 0:
					for i in range(gap):
						gridRow.Add(null)
				lastColumn = column.Key
				
				widget = column.Value
				bitmap = widget.Render()
				gridRow.Add(Pair [of IWidget, Bitmap](widget, bitmap))
		
		rowHeights = array [of int](grid.Count)
		columnWidths = array [of int](columnCount)
		i = 0
		for row in grid:
			if row == null:
				rowHeights[i++] = 0
				continue
			
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
					pair.V1.Position = (x, y)
					bitmap.Blit(x, y, pair.V2)
				x += columnWidths[j++]
			
			y += rowHeights[i++]
		
		return bitmap
