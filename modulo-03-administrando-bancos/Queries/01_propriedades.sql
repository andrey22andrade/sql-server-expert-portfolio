/********************************
 Propriedades de Bancos de Dados
*********************************/

USE master
GO

/**********************************
 sys.databases
***********************************/ 
SELECT * FROM sys.databases

SELECT [name] AS Banco,collation_name AS Collation,
CASE [compatibility_level]
WHEN 80 THEN 'SQL2000'
WHEN 90 THEN 'SQL2005'
WHEN 100 THEN 'SQL2008' 
WHEN 110 THEN 'SQL2012'
WHEN 120 THEN 'SQL2014' 
WHEN 130 THEN 'SQL2016'
WHEN 140 THEN 'SQL2017'
WHEN 150 THEN 'SQL2019'
WHEN 160 THEN 'SQL2022'
ELSE ltrim(str(compatibility_level)) END AS VersaoSQL,
recovery_model_desc AS RecoveryModel,
page_verify_option_desc AS PageVerify,
CASE WHEN is_auto_close_on = 1 THEN 'ON' ELSE 'OFF' END AS [Auto_Close],
CASE WHEN is_auto_shrink_on = 1 THEN 'ON' ELSE 'OFF' END AS [Auto_Shrink],
CASE WHEN is_read_committed_snapshot_on = 1 THEN 'ON' ELSE 'OFF' END AS [Read_Committed_Snapshot]

FROM MASTER.sys.databases
WHERE database_id > 4
ORDER BY 1

/**********************************
 sys.databases + sys.master_files
***********************************/

SELECT * FROM sys.databases
SELECT * FROM sys.master_files

;WITH CTE_TamanhoBD_Dados AS (
SELECT b.name AS Banco, sum((a.size * 8) / 1024) AS TamanhoMB_Dados
FROM sys.master_files a
JOIN sys.databases b ON a.database_id = b.database_id
WHERE a.type_desc <> 'LOG'
GROUP BY b.name),

CTE_TamanhoBD_Log AS (
SELECT b.name as Banco, sum((a.size * 8) / 1024) AS TamanhoMB_Log
FROM sys.master_files a
JOIN sys.databases b ON a.database_id = b.database_id
WHERE a.type_desc = 'LOG'
GROUP BY b.name)

SELECT a.name AS Banco,a.recovery_model_desc AS [Recovery],
CASE a.compatibility_level
WHEN 80 THEN 'SQL2000'
WHEN 90 THEN 'SQL2005'
WHEN 100 THEN 'SQL2008' 
WHEN 110 THEN 'SQL2012' 
WHEN 120 THEN 'SQL2014' 
WHEN 130 THEN 'SQL2016'
WHEN 140 THEN 'SQL2017'
WHEN 150 THEN 'SQL2019'
WHEN 160 THEN 'SQL2022'
ELSE ltrim(str(compatibility_level)) END AS Versão,
a.collation_name AS Collation, 
b.TamanhoMB_Dados, c.TamanhoMB_Log

FROM master.sys.databases a
JOIN CTE_TamanhoBD_Dados b ON a.name = b.Banco
JOIN CTE_TamanhoBD_Log c ON a.name = c.Banco
WHERE database_id > 4
ORDER BY TamanhoMB_Dados DESC

/**********************************
 Função DATABASEPROPERTYEX
 https://learn.microsoft.com/en-us/sql/t-sql/functions/databasepropertyex-transact-sql?view=sql-server-ver16
***********************************/
SELECT DATABASEPROPERTYEX('AdventureWorks', 'Collation')
SELECT DATABASEPROPERTYEX('AdventureWorks', 'Recovery')
SELECT DATABASEPROPERTYEX('AdventureWorks', 'Status')
GO

/*
ONLINE: Banco liberado para uso.
OFFLINE: Banco fora do ar, arquivos liberados no disco.
RESTORING: No meio do processo de Restore.
RECOVERING: Em processo de recuperação.
SUSPECT: Banco corrompido.
EMERGENCY: Acesso restrito ao administrador, normalmente utilizado em recuperações.
*/

SELECT DATABASEPROPERTYEX('AdventureWorks', 'IsAutoShrink')
GO