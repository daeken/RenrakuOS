namespace Renraku.Kernel

import System.Collections

public interface IGuiProvider:
	pass
	
public class GuiService():
	override ServiceId:
		get:
			return 'gui'
			
	private WindowList as ArrayList
	private Video as IVideoProvider
	def constructor():
		Video = cast(IVideoProvider, Context.Service['video'])
		Video.Graphical = true
		
		WindowList = ArrayList()
		
		Context.Register(self)
		
	def CreateNewWindow(x as int, y as int, width as int, height as int, title as string):
		WindowList.Add(Window(WindowList.Count, x, y, width, height, title))
		RedrawWindows()
		
	def RemoveWindow(id as int):
		WindowList.RemoveAt(id)
		i = id
		while i < WindowList.Count:
			window = cast(Window, WindowList[i])
			window.Id = i
			i += 1
		SetWindowFocus(i)
		
	def SetWindowFocus(id as int):
		focused = cast(Window, WindowList[id])
		RemoveWindow(id)
		CreateNewWindow(focused.X, focused.Y, focused.Width, focused.Height, focused.Title)
		RedrawWindows()
		
	def RedrawWindows():
		Video.Fill(0, 0, 320, 200, 0)
		i = 0
		color as byte
		while i < WindowList.Count:
			if i == WindowList.Count-1:
				color = 15
			else:
				color = 7
			window = cast(Window, WindowList[i])
			Video.Fill(window.X, window.Y, window.Width, window.Height, color)
			i+=1
		Video.WaitForRefresh()
		
public class Window():
	public Id as int
	public X as int
	public Y as int
	public Width as int
	public Height as int
	public Title as string
	
	def constructor(_Id as int, _x as int, _y as int, _width as int, _height as int, _title):
		Id = _Id
		X = _x
		Y = _y
		Width = _width
		Height = _height
		Title = _title
		