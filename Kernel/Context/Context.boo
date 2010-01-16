namespace Renraku.Kernel

import System
import System.Collections

public interface IService:
	ServiceId as string:
		get:
			pass

class EnvVariable:
	public Key as string
	public Value as string

public class Context:
	Services as ArrayList
	Parent as Context
	Environment as ArrayList
	
	# When running natively, CurrentContext will be intrinsic'd away
	# TLSContext is ONLY used for Hosted mode!
	[ThreadStatic] static TLSContext as Context
	public static CurrentContext as Context:
		get:
			return TLSContext
		set:
			TLSContext = value
	
	public static Service [id as string] as IService:
		get:
			return CurrentContext.GetService(id)
	
	public static Environ as ArrayList:
		get:
			return CurrentContext.Environment
	
	public def constructor():
		Services = ArrayList(4)
		Environment = ArrayList(4)
		Parent = null
	
	public static def Copy() as Context:
		context = CurrentContext
		new = Context()
		i = 0
		while i < context.Services.Count:
			if context.Services[i] != null:
				new.Services.Add(context.Services[i++])
		i = 0
		while i < context.Environment.Count:
			env = cast(EnvVariable, context.Environment[i++])
			newenv = EnvVariable()
			newenv.Key = env.Key
			newenv.Value = env.Value
			new.Environment.Add(newenv)
		return new
	
	public static def GetService(id as string) as IService:
		context = CurrentContext
		i = 0
		while i < context.Services.Count:
			service = cast(IService, context.Services[i])
			if service != null and service.ServiceId == id:
				return service
			i++
		
		return null
	
	public static def Register(service as IService):
		context = CurrentContext
		i = 0
		empty = -1
		while i < context.Services.Count:
			oldService = cast(IService, context.Services[i])
			if oldService == null:
				empty = i
			elif oldService.ServiceId == service.ServiceId:
				context.Services[i] = service
				return
			i++
		
		if empty == -1:
			context.Services.Add(service)
		else:
			context.Services[empty] = service
	
	public static def Remove(id as string):
		context = CurrentContext
		i = 0
		while i < context.Services.Count:
			service = cast(IService, context.Services[i])
			if service != null and service.ServiceId == id:
				context.Services[i] = null
				break
			i++

	public static def Push () as Context:
		context = CurrentContext.Copy()
		context.Parent = CurrentContext
		CurrentContext = context
		return context

	public static def Pop ():
		context = CurrentContext
		if context.Parent != null:
			CurrentContext = context.Parent
	
	public static def GetVar (key as string) as string:
		context = CurrentContext
		i = 0
		while i < context.Environment.Count:
			env = cast(EnvVariable, context.Environment[i++])
			if env.Key == key:
				return env.Value
		return null
	
	public static def SetVar (key as string, value as string):
		context = CurrentContext
		i = 0
		while i < context.Environment.Count:
			env = cast(EnvVariable, context.Environment[i++])
			if env.Key == key:
				env.Value = value
				return
		env = EnvVariable()
		env.Key = key
		env.Value = value
		context.Environment.Add(env)	
