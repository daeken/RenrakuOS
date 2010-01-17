Task service:
=============

The task service manages the startup and execution of tasks (threads).  In hosted mode, this will generally map directly to .NET threads; running natively, scheduling will be handled here as well, and System.Thread.Thread will map onto this service.

Interface (ITaskProvider):
--------------------------

- `callable TaskCallable(*args) as void` -- Task entrypoint callable.  Takes a variable number of arguments.
- `def StartTask(taskFunc as TaskCallable, args as (object)) as void` -- Starts a new task, given the entrypoint callable and arguments array.
