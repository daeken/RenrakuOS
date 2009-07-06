namespace Renraku.Compiler

static class Blockifier:
	def Blockify(assembly as duck) as duck:
		return Transform.MethodBodies(assembly, Body)
	
	def Body(body as duck) as duck:
		blocks as duck = {0 : ['block', 0]}
		for i in range(len(body)-1):
			inst = body[i+1]
			for j in range(len(inst)-2):
				subinst = inst[j+2]
				if subinst[0] == 'branch':
					blocks[subinst[2]] = []
					if subinst[1] != null: # Conditional
						blocks[subinst[3]] = []
		
		curBlock = -1
		for i in range(len(body)-1):
			inst = body[i+1]
			if inst[1] in blocks:
				curBlock = inst[1]
			for j in range(len(inst)-2):
				blocks[curBlock].Add(inst[j+2])
		
		ret = ['body']
		for block as duck in blocks:
			ret.Add(block.Value)
		
		return ret
