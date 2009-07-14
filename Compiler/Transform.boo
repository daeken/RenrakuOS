namespace Renraku.Compiler

import System.Collections

static class Transform:
	def Types(assembly as duck, func as duck) as duck:
		ret = ['top']
		for i in range(len(assembly) - 1):
			type = assembly[i+1]
			if type[0] != 'type':
				ret.Add(type)
				continue
			subret = func(type)
			if subret == null:
				ret.Add(type)
			else:
				ret.Add(subret)
		
		return ret
	
	def Interfaces(assembly as duck, func as duck) as duck:
		ret = ['top']
		for i in range(len(assembly) - 1):
			type = assembly[i+1]
			if type[0] != 'interface':
				ret.Add(type)
				continue
			subret = func(type)
			if subret == null:
				ret.Add(type)
			else:
				ret.Add(subret)
		
		return ret
	
	def Fields(assembly as duck, func as duck) as duck:
		def transformTypes(type as duck) as duck:
			ret = ['type', type[1], type[2]]
			for i in range(len(type) - 3):
				member = type[i+3]
				if member[0] == 'field':
					subret = func(member)
					if subret == null:
						ret.Add(member)
					else:
						ret.Add(subret)
				else:
					ret.Add(member)
			
			return ret
		
		return Types(assembly, transformTypes)
	
	def Methods(assembly as duck, func as duck) as duck:
		def transformTypes(type as duck) as duck:
			ret = ['type', type[1], type[2]]
			for i in range(len(type) - 3):
				member = type[i+3]
				if member[0] == 'method':
					subret = func(member)
					if subret == null:
						ret.Add(member)
					else:
						ret.Add(subret)
				else:
					ret.Add(member)
			
			return ret
		
		return Types(assembly, transformTypes)
	
	def InterfaceMethods(assembly as duck, func as duck) as duck:
		def transformTypes(type as duck) as duck:
			ret = ['interface', type[1], type[2]]
			for i in range(len(type) - 3):
				member = type[i+3]
				if member[0] == 'method':
					subret = func(member)
					if subret == null:
						ret.Add(member)
					else:
						ret.Add(subret)
				else:
					ret.Add(member)
			
			return ret
		
		return Interfaces(assembly, transformTypes)
	
	def MethodBodies(assembly as duck, func as duck) as duck:
		def transformMethods(method as duck) as duck:
			subret = func(method[5])
			if subret != null:
				method[5] = subret
			return method
		
		return Methods(assembly, transformMethods)
	
	def BlockInstructions(assembly as duck, func as duck) as duck:
		def transformBodies(body as duck) as duck:
			ret = ['body']
			for i in range(len(body) - 1):
				block = body[i+1]
				subblock = ['block', block[1]]
				ret.Add(subblock)
				for j in range(len(block) - 2):
					subret = func(block[j+2])
					if subret isa IEnumerable:
						for inst in subret:
							subblock.Add(inst)
					elif subret == null:
						subblock.Add(block[j+2])
			
			return ret
		
		return MethodBodies(assembly, transformBodies)
