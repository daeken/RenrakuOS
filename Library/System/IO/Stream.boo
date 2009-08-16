namespace System.IO

public abstract class Stream:
	abstract def Read(buffer as (byte), offset as int, count as int) as int:
		pass
	
	abstract def Write(buffer as (byte), offset as int, count as int):
		pass
