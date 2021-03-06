namespace Renraku.Gui

public abstract class IWidget:
	_Position as (int)
	Position as (int):
		get:
			return _Position
		set:
			_Position = value
	
	_Size as (int)
	Size as (int):
		get:
			return _Size
		set:
			_Size = value
	
	_Expandable as bool = false
	virtual Expandable as bool:
		get:
			return _Expandable
		set:
			pass
	
	virtual def Clicked(x as int, y as int, down as bool, button as int) as void:
		pass
	
	virtual def Dragging(x as int, y as int, button as int) as void:
		pass
	
	abstract def Render() as Bitmap:
		pass
	
	virtual def Render(width as int, height as int) as Bitmap:
		return Render()
	
	def Inside(x as int, y as int):
		if Position == null or Size == null:
			return false
		return (
				x >= Position[0] and x < Position[0] + Size[0] and 
				y >= Position[1] and y < Position[1] + Size[1]
			)
