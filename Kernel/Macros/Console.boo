import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

macro print(str as Expression):
	yield [| System.Console.WriteLine($str) |]

macro prints(str as Expression):
	yield [| System.Console.Write($str) |]
	yield [| System.Console.WriteChar(char(' ')) |]

macro printhex(num as Expression):
	yield [| System.Console.WriteHex($num) |]

macro printaddr(obj as Expression):
	yield [| System.Console.WriteHex(Pointer [of uint].GetAddr($obj)) |]
