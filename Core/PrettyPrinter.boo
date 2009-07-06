import System.Collections
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

static class PrettyPrinter:
	def Print(obj as duck, level as int) as string:
		if obj isa string:
			return obj
		elif obj isa IEnumerable:
			if len(obj) == 0:
				return '[]'
			elif len(obj) == 1:
				return '[' + Print(obj[0], level+1) + ']'
			elif len(obj) == 2 or len(obj) == 3:
				newlines = false
			else:
				newlines = true
			
			ret = '['
			for elem in obj:
				ret += Print(elem, level+1) + ', '
				if newlines:
					ret += '\n'
					ret += '  ' * level
			if newlines:
				return ret[:-3-(level*2)] + ']'
			else:
				return ret[:-2] + ']'
		else:
			return obj.ToString()

macro pprint(obj):
	yield [| print PrettyPrinter.Print($obj, 1) |]
