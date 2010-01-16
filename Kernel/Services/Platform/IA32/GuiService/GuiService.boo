namespace Renraku.Kernel

import System.Collections

public interface IGuiProvider:
	def CreateNewWindow(x as int, y as int, width as int, height as int, title as string):
		pass
		
	def RemoveWindow(id as int):
		pass
		
	def SetWindowFocus(id as int):
		pass
	
	def RedrawWindows():
		pass
	
	def StartGui():
		pass
	
	def StopGui():
		pass
		
public class GuiService(IService, IGuiProvider):
	override ServiceId:
		get:
			return 'gui'
			
	private WindowList as ArrayList
	private Video as IVideoProvider
	private mouseservice as IMouseProvider
	private mouse as Mouse_
	private Gui = false
	def constructor():
		Video = cast(IVideoProvider, Context.Service['video'])		
		mouseservice = cast(IMouseProvider, Context.Service['mouse'])
		WindowList = ArrayList(10)
		mouse = Mouse_(160, 100)
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
		i = 0
		while i < WindowList.Count:
			if i == WindowList.Count-1:
				color = 15
			else:
				color = 7
			window = cast(Window, WindowList[i])
			Video.Fill(window.X, window.Y, window.Width, window.Height, color)
			i+=1
		
	def DrawMouse():
		Video.Fill(mouse.X, mouse.Y, 5, 5, 4)
		
	def StartGui():
		print 'starting gui'
		Video.Graphical = true
		Gui = true
		while Gui:
			evt = mouseservice.Read()
			if evt.Type == MouseEventType.ButtonDown:
				pass
			elif evt.Type == MouseEventType.ButtonUp:
				pass
			elif evt.Type == MouseEventType.Movement:
				if evt.Delta[0] < 0:
					mouse.X -= (-evt.Delta[0]) >> 1
				else:
					mouse.X += evt.Delta[0] >> 1
				if evt.Delta[1] < 0:
					mouse.Y += (-evt.Delta[1]) >> 1
				else:
					mouse.Y -= evt.Delta[1] >> 1
				
				if mouse.X > 315:
					mouse.X = 315
				elif mouse.X < 5:
					mouse.X = 5
				if mouse.Y > 195:
					mouse.Y = 195
				elif mouse.Y < 5:
					mouse.Y = 5
			Video.Clear()
			RedrawWindows()
			DrawMouse()
			Video.SwapBuffers()
		Video.Graphical = false
		
	def StopGui():
		Gui = false
			
public class Window():
	public Id as int
	public X as int
	public Y as int
	public Width as int
	public Height as int
	public Title as string
	
	def constructor(_Id as int, _x as int, _y as int, _width as int, _height as int, _title as string):
		Id = _Id
		X = _x
		Y = _y
		Width = _width
		Height = _height
		Title = _title
		
public class Mouse_():
	public X as int
	public Y as int
	
	def constructor(_x as int, _y as int):
		X = _x
		Y = _y