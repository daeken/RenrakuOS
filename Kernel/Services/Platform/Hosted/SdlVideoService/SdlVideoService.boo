namespace Renraku.Kernel

import SdlDotNet.Core
import SdlDotNet.Graphics
import SdlDotNet.Graphics.Primitives
import SdlDotNet.Input
import System.Drawing
import Boo.Lang.Builtins

public class Image:
	static def FromFile(fn as string):
		bitmap = Bitmap(System.Drawing.Image.FromFile(fn))
		
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
		return Image(bitmap.Width, bitmap.Height, pixels)
	
	public Width as int
	public Height as int
	public Pixels as (Color, 2)
	def constructor(width as int, height as int, pixels as (Color, 2)):
		Width = width
		Height = height
		Pixels = pixels

public interface IVideoProvider:
	event Tick as callable(IVideoProvider)
	
	def SetMode(width as int, height as int, bits as int) as void:
		pass
	
	def SetPixel(x as int, y as int, color as Color):
		pass
	
	def DrawLine(x1 as int, y1 as int, x2 as int, y2 as int, color as Color):
		pass
	
	def DrawRect(x1 as int, y1 as int, x2 as int, y2 as int, lineColor as Color, fillColor as Color):	
		pass
	
	def DrawImage(x as int, y as int, image as Renraku.Kernel.Image):
		pass
	
	def SwapBuffers():
		pass

public static class VideoProvider:
	public Service as IVideoProvider:
		get:
			return cast(IVideoProvider, Context.Service['video'])

public class SdlVideoService(IService, IVideoProvider):
	override ServiceId:
		get:
			return 'video'
	
	Screen as Surface = null
	public event Tick as callable(IVideoProvider)
	
	def constructor():
		Context.Register(self)
		print 'SDL video service initialized.'
	
	def SetMode(width as int, height as int, bits as int) as void:
		taskServ = cast(ITaskProvider, Context.Service['task'])
		taskServ.StartTask() do:
			Video.WindowIcon()
			Screen = Video.SetVideoMode(width, height)
			Video.WindowCaption = 'Renraku'
			Mouse.ShowCursor = false
			
			Events.Quit += do(sender, e):
				Events.QuitApplication()
			Events.Tick += do(sender, e):
				Tick(self)
			Events.Run()
	
	def SetPixel(x as int, y as int, color as Color):
		Screen.Lock()
		Screen.Draw(
				Point(x, y), 
				color
			)
		Screen.Unlock()
	
	def DrawLine(x1 as int, y1 as int, x2 as int, y2 as int, color as Color):
		Screen.Draw(
				Line(x1, y1, x2, y2), 
				color
			)
	
	def DrawRect(x1 as int, y1 as int, x2 as int, y2 as int, lineColor as Color, fillColor as Color):	
		DrawLine(x1, y1, x1, y2, lineColor) # Left
		DrawLine(x1, y1, x2, y1, lineColor) # Top
		DrawLine(x2, y1, x2, y2, lineColor) # Right
		DrawLine(x1, y2, x2, y2, lineColor) # Bottom
		
		Screen.Fill(
				Rectangle(
						x1+1, y1+1, 
						x2-x1-1, y2-y1-1
					), 
				fillColor
			)
	
	def DrawImage(x as int, y as int, image as Renraku.Kernel.Image):
		Screen.SetPixels(
				Point(x, y), 
				image.Pixels
			)
	
	def SwapBuffers():
		Screen.Update()
		Screen.Fill(Color.LightBlue)
