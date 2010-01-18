namespace Renraku.Kernel

import System.Collections.Generic
import System.Drawing

public interface IGuiProvider:
	def Start() as void:
		pass
	
	def CreateWindow(func as callable) as Window:
		pass

public static class GuiProvider:
	public Service as IGuiProvider:
		get:
			return cast(IGuiProvider, Context.Service['gui'])

public class Window:
	Gui as IGuiProvider
	
	public Title as string
	_Dimensions as (int)
	public Dimensions as (int):
		get:
			return _Dimensions
		set:
			_Dimensions = value
			Reshape()
	_Position as (int)
	public Position as (int):
		get:
			return _Position
		set:
			_Position = value
	_Visible as bool
	public Visible as bool:
		get:
			return _Visible
		set:
			_Visible = value
			Display()
	
	_Contents as object
	public Contents as object:
		get:
			return _Contents
		set:
			_Contents = value
	
	def constructor():
		Gui = GuiProvider.Service
		Title = 'Untitled Renraku Window'
		Dimensions = (400, 400)
		Position = (100, 100)
		Visible = false
	
	def Reshape():
		pass
	
	def Display():
		pass

public class GuiService(IService, IGuiProvider):
	override ServiceId:
		get:
			return 'gui'
	
	Video as IVideoProvider = null
	Windows as List [of Window]
	Pointer as (int)
	Dragging as Window = null
	
	def constructor():
		Context.Register(self)
		print 'GUI service initialized.'
	
	def Start():
		if Video != null:
			return
		
		Windows = List [of Window]()
		Pointer = (200, 300)
		
		Video = VideoProvider.Service
		Video.SetMode(800, 600, 24)
		Video.Tick += Tick
		Mouse = MouseProvider.Service
		Mouse.Button += Button
		Mouse.Motion += Motion
	
	def CreateWindow(func as callable) as Window:
		window = Window()
		if func != null:
			func(window)
		Windows.Add(window)
		return window
	
	def Tick():
		for window in Windows:
			if not window.Visible:
				continue
			
			Video.DrawRect(
					window.Position[0], 
					window.Position[1], 
					window.Position[0] + window.Dimensions[0] + 1, 
					window.Position[1] + window.Dimensions[1] + 25 + 1, 
					Color.Black, 
					Color.White
				)
			# Titlebar
			Video.DrawRect(
					window.Position[0], 
					window.Position[1], 
					window.Position[0] + window.Dimensions[0] + 1, 
					window.Position[1] + 25, 
					Color.Black, 
					Color.Blue
				)
			
			if window.Contents == null:
				continue
			
			if window.Contents.GetType() == Renraku.Kernel.Image:
				Video.DrawImage(
						window.Position[0] + 1, 
						window.Position[1] + 26, 
						cast(Renraku.Kernel.Image, window.Contents)
					)
		
		Video.DrawRect(
				Pointer[0]-5, 
				Pointer[1]-5, 
				Pointer[0]+5, 
				Pointer[1]+5, 
				Color.Green, 
				Color.Green
			)
		
		Video.SwapBuffers()
	
	def InWindow(x as int, y as int) as Window:
		for window in Windows:
			if window.Position[0] > x or window.Position[1] > y:
				break
			if window.Position[0] + window.Dimensions[0] < x or window.Position[1] + window.Dimensions[1] + 25 < y:
				break
			return window
		return null
	
	def Button(down as bool, button as int):
		if down and button == 1:
			window = InWindow(Pointer[0], Pointer[1])
			if window == null:
				return
			
			if window.Position[1] + 25 >= Pointer[1]:
				Dragging = window
		elif not down and button == 1:
			Dragging = null
	
	def Motion(x as int, y as int):
		Pointer[0] += x
		Pointer[1] += y
		
		if Dragging != null:
			Dragging.Position[0] += x
			Dragging.Position[1] += y
