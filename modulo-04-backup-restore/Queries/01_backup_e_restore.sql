/*****************
 Hands On - Backup
******************/

USE master
GO

CREATE DATABASE TestDB
GO


/**************************
 BACKUP Device
***************************/

-- Cria DEVICE
EXEC master.dbo.sp_addumpdevice  
@devtype = N'disk', 
@logicalname = N'BackupMaster', 
@physicalname = N'C:\_HandsOn_AdmSQL\Backup\BackupMaster.bak'
GO

-- Backup Device
BACKUP DATABASE master TO BackupMaster

-- Backup File
BACKUP DATABASE master TO DISK = 'C:\_HandsOn_AdmSQL\Backup\BackupMaster.bak'
GO

/***********************************
 Habilitar Compressão na Instância
************************************/
EXEC sp_configure 'show advanced options', 1
RECONFIGURE

EXEC sp_configure 'backup compression default', 1
RECONFIGURE

/*************************************** 
 Hands On Backup e Restore
****************************************/
USE TestDB
GO

CREATE TABLE dbo.Clientes 
(ClienteID INT NOT NULL PRIMARY KEY,
Nome VARCHAR(50),
Telefone VARCHAR(20))
GO

SELECT * FROM TestDB.dbo.Clientes
GO

/******************
 1) Backup FULL
*******************/
INSERT dbo.Clientes VALUES (1,'Jose','1111-1111')
GO

BACKUP DATABASE TestDB TO DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH format,compression,stats=5


/******************
 2) Backup DIF
*******************/
INSERT dbo.Clientes VALUES (2,'Paula','2222-2222')
GO

BACKUP DATABASE TestDB TO DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH noinit,compression,differential

/******************
 3) Backup LOG
*******************/
INSERT dbo.Clientes VALUES (3,'Luana','3333-3333')
GO

BACKUP LOG TestDB TO DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH noinit,compression


RESTORE HEADERONLY FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak'
-- https://learn.microsoft.com/en-us/sql/t-sql/statements/restore-statements-headeronly-transact-sql?view=sql-server-ver16
/* BackupType
1 = FULL
2 = Transaction log
4 = File
5 = Differential database
6 = Differential file
7 = Partial
8 = Differential partial
*/

/***************************************
 4) Backup Log Reflexo Medular (RM)
****************************************/
INSERT dbo.Clientes VALUES (4,'Landry','4444-4444')
GO

-- SIMULANDO FALHA: Parar o serviço do SQL Server e renomear o arquivo de dados

BACKUP LOG TestDB TO DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH noinit,compression,no_truncate
--WITH CONTINUE_AFTER_ERROR or WITH NO_TRUNCATE

/****************************
 Restore
*****************************/
-- Obtém informações de um Backup
RESTORE FILELISTONLY FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH file=1

RESTORE DATABASE TestDB FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH file=1, norecovery, replace
RESTORE DATABASE TestDB FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH file=2, norecovery
RESTORE LOG TestDB FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH file=3, norecovery
RESTORE LOG TestDB FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH file=4, recovery

-- RESTORE LOG TestDB WITH RECOVERY

SELECT * FROM TestDB.dbo.Clientes

/****************************
 Restore STANDBY
*****************************/
RESTORE DATABASE TestDB FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH file=1, norecovery, replace
RESTORE DATABASE TestDB FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH file=2, norecovery
RESTORE LOG TestDB FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH file=3, standby = 'C:\_HandsOn_AdmSQL\Backup\TestDB.std'
RESTORE LOG TestDB FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\TestDB.bak' WITH file=4, recovery

SELECT * FROM TestDB.dbo.Clientes

/***********************************
 Histórico Backup
 https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/backupset-transact-sql?view=sql-server-ver16
************************************/
SELECT * FROM msdb..backupset

-- Bancos sem Backup nos últimos 7 dias
SELECT [name] as Banco, recovery_model_desc AS RecoveryModel, create_date AS DataCriacao 
FROM sys.databases
WHERE database_id > 4 AND NAME NOT IN (
SELECT DISTINCT database_name FROM msdb..backupset
WHERE backup_start_date > DATEADD(DAY,-8,GETDATE()) AND  TYPE <> 'L')
/*
D = Database
I = Differential database
L = Log
F = File or filegroup
G = Differential file
P = Partial
Q = Differential partial
*/

-- Backups de um determinado Banco
SELECT a.backup_start_date AS Datainicio,a.backup_finish_date AS DataTermino,a.[database_name] AS Banco, 
CASE a.[type]
WHEN 'D' THEN 'FULL'
WHEN 'I' THEN 'DIF'
WHEN 'L' THEN 'LOG' END AS TipoBackup,
b.physical_device_name AS ArquivoBackup,
a.user_name AS usuario, a.is_copy_only, a.is_snapshot
FROM  msdb..backupset a
JOIN msdb..backupmediafamily b ON b.media_set_id = a.media_set_id
WHERE 1=1
and database_name = 'TestDB'
--and a.type <> 'L'
and backup_finish_date >= '20220601'
ORDER BY Banco,backup_finish_date DESC


-- Exclui banco
USE master
GO

DROP DATABASE IF EXISTS TestDB
GO