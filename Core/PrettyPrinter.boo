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
			elif len(obj) == 2:
				return '[' + Print(obj[0], level+1) + ', ' + Print(obj[1], level+1) + ']'
			
			ret = '['
			for elem in obj:
				ret += Print(elem, level+1) + ', \n'
				ret += '  ' * level
			return ret[:-3-(level*2)] + ']'
		else:
			return obj.ToString()

macro pprint(obj):
	yield [| print PrettyPrinter.Print($obj, 1) |]
