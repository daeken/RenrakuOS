namespace Renraku.Apps

import Renraku.Kernel

class Exclaim(Application, IKeyboardProvider, IService):
	override ServiceId:
		get:
			return 'keyboard'
	
	override Name as string:
		get:
			return 'exclaim'

	override HelpString as string:
		get:
			return 'Nested Context example test capsule.'
	
	Keyboard as IKeyboardProvider
	def Run(_ as (string)):
		print 'Type a 1 and see what happens...'
		
		Keyboard = Context.Service['keyboard']
		context = Context.Push()
		context.Register(self)
		
		Shell().Run(null)
		
		Context.Pop()
	
	def HasData() as bool:
		return Keyboard.HasData()
	
	def Read() as char:
		ch = Keyboard.Read()
		if ch == char('1'):
			return char('!')
		return ch
