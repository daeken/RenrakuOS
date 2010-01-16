Task service:
=============

The task service manages the startup and execution of tasks (threads).  In hosted mode, this will generally map directly to .NET threads; running natively, scheduling will be handled here as well, and System.Thread.Thread will map onto this service.

Interface (ITaskProvider):
--------------------------

- `callable TaskCallable(args as (object)) as void` -- Task entrypoint callable.  Takes an array of arguments (XXX: Should this be a 'params' argument, so that the unpacking is done by the CLR?  Can Boo do this?)
- `def StartTask(taskFunc as TaskCallable, args as (object)) as void` -- Starts a new task, given the entrypoint callable and arguments array.
