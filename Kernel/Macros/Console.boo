namespace Renraku.Kernel

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching

macro print(str as string):
	yield [| Console.PrintLine($str) |]

macro printhex(num as Expression):
	yield [| Console.PrintHex($num) |]

macro printaddr(obj as Expression):
	yield [| Console.PrintHex(Pointer [of uint].GetAddr($obj)) |]
