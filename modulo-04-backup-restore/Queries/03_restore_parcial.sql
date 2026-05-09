/*****************
 Hands On - Backup
******************/

USE master
GO

CREATE DATABASE TestDB
GO

CREATE DATABASE TestDB_Parcial
GO

/*************************************** 
 Hands On Restore Parcial
****************************************/
CREATE TABLE TestDB.dbo.Clientes 
(ClienteID INT NOT NULL PRIMARY KEY,
Nome VARCHAR(50),
Telefone VARCHAR(20))
GO

/******************
 1) Backup FULL
*******************/
INSERT TestDB.dbo.Clientes VALUES (1,'Jose','1111-1111')
GO

DECLARE @Arquivo varchar(4000)
set @Arquivo = 'C:\_HandsOn_AdmSQL\Backup\TestDB_' + convert(char(8),getdate(),112)+ '_H' + replace(convert(char(8),getdate(),108),':','') + '.bak'
--SELECT @Arquivo

BACKUP DATABASE TestDB TO DISK = @Arquivo WITH format,compression,stats=5
GO

/******************
 3) Backup LOG
*******************/
INSERT TestDB.dbo.Clientes VALUES (2,'Paula','2222-2222') -- 15:47
INSERT TestDB.dbo.Clientes VALUES (3,'Luana','3333-3333') -- 15:50
INSERT TestDB.dbo.Clientes VALUES (4,'Landry','4444-4444') -- 15:53

SELECT * FROM TestDB.dbo.Clientes


DECLARE @Arquivo varchar(4000)
set @Arquivo = 'C:\_HandsOn_AdmSQL\Backup\TestDB_' + convert(char(8),getdate(),112)+ '_H' + replace(convert(char(8),getdate(),108),':','') + '.trn'

BACKUP LOG TestDB TO DISK = @Arquivo WITH format,compression
GO

/****************************
 Restore STANDBY
*****************************/
RESTORE DATABASE TestDB_Parcial FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB_20260509_H131423.bak' WITH file=1, norecovery, replace,
MOVE 'TestDB' TO 'C:\MSSQL_Data\TestDB_Parcial.mdf',
MOVE 'TestDB_log' TO 'C:\MSSQL_Data\TestDB_Parcial_log.ldf'

RESTORE LOG TestDB_Parcial FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB_20260509_H132104.trn' WITH  
standby = 'C:\_HandsOn_AdmSQL\Backup\TestDB_Parcial.std',
stopat = '20250509 13:28:00.000'

RESTORE LOG TestDB_Parcial FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB_20260509_H132104.trn' WITH  
standby = 'C:\_HandsOn_AdmSQL\Backup\TestDB_Parcial.std',
stopat = '20250509 13:29:00.000'

RESTORE LOG TestDB_Parcial WITH recovery

SELECT * FROM TestDB_Parcial.dbo.Clientes

-- Exclui banco
use master
GO

ALTER DATABASE TestDB SET single_user WITH rollback immediate
DROP DATABASE IF exists TestDB
ALTER DATABASE TestDB_Parcial SET single_user WITH rollback immediate
DROP DATABASE IF exists TestDB_Parcial
GO