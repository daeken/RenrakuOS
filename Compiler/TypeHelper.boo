namespace Renraku.Compiler

import System
import Boo.Lang.PatternMatching
import Mono.Cecil

static class TypeHelper:
	Corlib as ModuleDefinition
	def constructor():
		resolver= DefaultAssemblyResolver()
		assembly = AssemblyNameReference()
		assembly.Name = 'mscorlib'
		assembly.Version = Version('2.0.0.0')
		Corlib = resolver.Resolve(assembly).MainModule
	
	def GetSize(type as duck) as int:
		if type isa TypeDefinition:
			if not type.IsValueType:
				return 4
			elif type.IsEnum:
				return 4
			
			size = 0
			for field as FieldDefinition in type.Fields:
				subtype = field.FieldType
				if subtype isa TypeDefinition:
					size += 4
				else:
					size += GetSize(subtype)
			return size
		elif type isa TypeReference:
			if type.Name == 'Pointer`1':
				return 4
			elif type.Name.EndsWith('[]'):
				return 4
		
		match type.ToString():
			case 'System.Boolean' | 'System.Byte' | 'System.SByte': return 1
			case 'System.Char' | 'System.Int16' | 'System.UInt16': return 2
			case 'System.Int32' | 'System.UInt32': return 4
			case 'System.String' | 'System.Object': return 4
			otherwise:
				print type.Name
				print 'Unknown type in GetTypeSize:', type
	
	def ToRegister(letter as string, type as duck) as string:
		match GetSize(type):
			case 1: return letter + 'l'
			case 2: return letter + 'x'
			case 4: return 'e' + letter + 'x'
			otherwise:
				print 'Unknown size in ToRegister:', type, GetSize(type)
	
	def SanitizeName(name as string) as string:
		return name.Replace('`', '_').Replace('<', '.').Replace('>', '.').Replace('[', '.').Replace(']', '.')
	
	def AnnotateName(member as duck, withType as bool):
		if member isa MethodReference:
			name = member.Name + '$' + SanitizeName(member.ReturnType.ReturnType.ToString()) + '$'
			
			for parameter as ParameterDefinition in member.Parameters:
				name += SanitizeName(parameter.ParameterType.ToString()) + '$'
		elif member isa FieldReference:
			name = member.Name + '$' + SanitizeName(member.FieldType.ToString())
		
		if withType:
			return member.DeclaringType.Name + '.' + name
		else:
			return name
	
	def IsDelegate(typeRef as TypeReference) as bool:
		if typeRef.FullName == 'System.Delegate':
			return true
		
		if typeRef isa TypeDefinition:
			type = cast(TypeDefinition, typeRef)
		else:
			type = typeRef.Module.Types[typeRef.FullName]
			if type == null:
				type = Corlib.Types[typeRef.FullName]
		
		if type == null or type.BaseType == null:
			return false
		else:
			return IsDelegate(type.BaseType)
