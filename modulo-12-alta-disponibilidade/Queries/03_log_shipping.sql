/************************************************
 Hands On: LogShipping Restabelecendo a Sincronia
*************************************************/

USE master
GO

BACKUP DATABASE HandsOn TO DISK = 'C:\LogShipping\Sinc\HandsOn.bak'
WITH FORMAT,COMPRESSION,stats=5

RESTORE DATABASE HandsOn FROM DISK = 'C:\LogShipping\Sinc\HandsOn.bak'
WITH NORECOVERY, REPLACE,
MOVE 'HandsOn' TO 'C:\MSSQL_Data\HandsOn.mdf',
MOVE 'HandsOn_Log' TO 'C:\MSSQL_Data\HandsOn_Log.ldf'
GO