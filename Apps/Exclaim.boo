namespace Renraku.Apps

import Renraku.Kernel

class Exclaim(Application, IKeyboardProvider, IService):
	override ServiceId:
		get:
			return 'keyboard'
	
	override Name as string:
		get:
			return 'exclaim'
	
	Keyboard as IKeyboardProvider
	def Run(_ as (string)):
		print 'Type a 1 and see what happens...'
		
		Keyboard = Context.Service['keyboard']
		oldContext = Context.CurrentContext
		Context.CurrentContext = Context.Copy()
		Context.Register(self)
		
		Shell().Run(null)
		
		Context.CurrentContext = oldContext
	
	def Read() as char:
		ch = Keyboard.Read()
		if ch == char('1'):
			return char('!')
		return ch
