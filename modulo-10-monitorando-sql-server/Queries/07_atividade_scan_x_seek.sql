/***********************************************
 - Gera atividade no SQL Server

 SQLServer:Buffer Manager:Page life expectancy
 (Max Server Memory em GB) / 4 * 300

 SQL Server:Access Methods\Full Scans/sec
 SQL Server:Access Methods\Index Searches/sec
  (Index Searches/sec) / (Full Scans/sec) > 1000
***********************************************/

-- Conexão 1 - SCAN
DECLARE @i INT = 1
DECLARE @Result INT
DECLARE @Result_MiddleName NVARCHAR(50)
WHILE @i > 0 BEGIN
SELECT @Result = COUNT(*) FROM AdventureWorks.Person.Person
WAITFOR DELAY '00:00:00.002'
END
GO

-- Conexão 2 - Seek
DECLARE @i INT = 1
DECLARE @Result INT
DECLARE @Result_MiddleName NVARCHAR(50)
WHILE @i > 0 BEGIN
SELECT @Result_MiddleName = MiddleName FROM AdventureWorks.Person.Person WHERE LastName = 'Abbas'
END
GO