namespace Renraku.Kernel

import System.Collections

public interface IService:
	ServiceId as string:
		get:
			pass

public class Context:
	Services as ArrayList
	Parent as Context
	
	public static CurrentContext as Context:
		get:
			return null # Intrinsic away!
		set:
			pass # Intrinsic away!
	
	public static Service [id as string] as IService:
		get:
			return CurrentContext.GetService(id)
	
	public def constructor():
		Services = ArrayList(4)
		Parent = null
	
	public static def Copy() as Context:
		context = CurrentContext
		new = Context()
		i = 0
		while i < context.Services.Count:
			if context.Services[i] != null:
				new.Services.Add(context.Services[i])
			i++
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
		if CurrentContext.Parent != null:
			CurrentContext = CurrentContext.Parent
