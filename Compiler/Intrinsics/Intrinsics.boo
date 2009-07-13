namespace Renraku.Compiler

import System

class ClassIntrinsic:
	Ns as string = null
	CName as string = null
	HasCtor as bool = true
	TypeArgs = 0
	public static Ctors = []
	public static Calls = []
	virtual def Ctor() as duck:
		raise Exception('Ctor called but not overloaded in intrinsic ' + self.GetType())
	virtual def CtorTypes(types as duck) as duck:
		raise Exception('CtorTypes called but not overloaded in intrinsic ' + self.GetType())
	
	def Register(cname as string):
		Ns, CName = cname.Split(('::', ), StringSplitOptions.None)
		if CName[len(CName)-1] == char(']'):
			CName, rest = CName.Split((char('['), ), StringSplitOptions.None)
			TypeArgs = len(rest.Split((char(','), ), StringSplitOptions.None))
			CName += '`' + TypeArgs.ToString()
		
		if HasCtor:
			if TypeArgs:
				Ctors.Add((Ns, CName, TypeArgs, CtorTypes))
			else:
				Ctors.Add((Ns, CName, TypeArgs, Ctor))
	
	def RegisterCall(name as string, func as duck) as duck:
		Calls.Add((Ns, CName, TypeArgs, name, func))
