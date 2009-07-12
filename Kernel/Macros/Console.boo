namespace Renraku.Kernel

import Boo.Lang.Compiler
import Boo.Lang.PatternMatching

macro print(str as string):
	yield [| Console.PrintLine($str) |]
