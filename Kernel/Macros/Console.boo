import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

macro print(str as string):
	yield [| System.Console.WriteLine($str) |]

macro printhex(num as Expression):
	yield [| System.Console.WriteHex($num) |]

macro printaddr(obj as Expression):
	yield [| System.Console.WriteHex(Pointer [of uint].GetAddr($obj)) |]
