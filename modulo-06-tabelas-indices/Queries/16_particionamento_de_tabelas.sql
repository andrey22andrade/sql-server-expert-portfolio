/************************************
 Hands On: Particionamento de Tabelas
*************************************/

USE master
GO

-- drop database BDparticao
CREATE DATABASE BDparticao ON
PRIMARY (NAME = BDparticao, FILENAME = 'C:\MSSQL_Data\BDparticao.mdf'),
FILEGROUP FG1 (NAME = BDparticao1, FILENAME = 'C:\MSSQL_Data\BDparticao1.ndf'),
FILEGROUP FG2 (NAME = BDparticao2, FILENAME = 'C:\MSSQL_Data\BDparticao2.ndf'),
FILEGROUP FG3 (NAME = BDparticao3, FILENAME = 'C:\MSSQL_Data\BDparticao3.ndf'),
FILEGROUP FG4 (NAME = BDparticao4, FILENAME = 'C:\MSSQL_Data\BDparticao4.ndf')
LOG ON
(NAME = BDparticao_log, FILENAME = 'C:\Aula\BDparticao_log.ldf')
GO

USE BDparticao
GO

CREATE PARTITION FUNCTION pf_Particao (INT)
AS RANGE LEFT
FOR VALUES (10, 20, 30)
GO

/* LEFT
 1) <= 10
 2) > 10 and <= 20
 3) > 20 and <= 30
 4) > 30
*/

/* RIGHT
 1) < 10
 2) >= 10 and < 20
 3) >= 20 and < 30
 4) >= 30
*/

CREATE PARTITION SCHEME ps_Particao
AS PARTITION pf_Particao 
TO (FG1, FG2, FG3, FG4)

/*
CREATE PARTITION SCHEME ps_Particao
AS PARTITION pf_Particao 
ALL TO ([PRIMARY])
*/

-- Create partitioned table

CREATE TABLE dbo.TesteParticao (
ColParticao int NOT NULL,
ColNome varchar(50) NOT NULL)
ON ps_Particao(ColParticao)

/* LEFT
 1) <= 10
 2) > 10 and <= 20
 3) > 20 and <= 30
 4) > 30
*/
INSERT TesteParticao VALUES (1, 'Nome 01') -- Part 1
INSERT TesteParticao VALUES (2, 'Nome 02') -- Part 1
INSERT TesteParticao VALUES (11,'Nome 11') -- Part 2
INSERT TesteParticao VALUES (12,'Nome 12') -- Part 2
INSERT TesteParticao VALUES (21,'Nome 21') -- Part 3
INSERT TesteParticao VALUES (22,'Nome 22') -- Part 3
INSERT TesteParticao VALUES (31,'Nome 31') -- Part 4
INSERT TesteParticao VALUES (32,'Nome 32') -- Part 4
GO

-- sys.partitions
SELECT * FROM sys.Partitions 
WHERE [object_id] = OBJECT_ID('dbo.TesteParticao')
ORDER BY partition_number
GO

/***********************************
 sys.partition_range_values
 https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-partition-range-values-transact-sql?view=sql-server-ver16

 sys.partition_functions
 https://learn.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-partition-functions-transact-sql?view=sql-server-ver16
************************************/
SELECT p.name,boundary_id,value 
FROM sys.partition_range_values r 
JOIN sys.partition_functions p ON r.function_id = p.function_id
GO

-- SELECT na tabela identificando a partição
SELECT ColParticao, ColNome, $Partition.pf_Particao(ColParticao) Particao
FROM dbo.TesteParticao
GO

/*********************************************
 Manutenção nas Partições
**********************************************/
SELECT * FROM sys.Partitions 
WHERE [object_id] = OBJECT_ID('dbo.TesteParticao')
ORDER BY partition_number
GO

SELECT ColParticao, ColNome, $Partition.pf_Particao(ColParticao) Particao
FROM dbo.TesteParticao
GO

-- MERGE

ALTER PARTITION FUNCTION pf_Particao()MERGE RANGE (30)

ALTER PARTITION FUNCTION pf_Particao()MERGE RANGE (20)

-- SPLIT

ALTER PARTITION SCHEME ps_Particao NEXT USED FG3;
ALTER PARTITION FUNCTION pf_Particao()SPLIT RANGE (20)

ALTER PARTITION SCHEME ps_Particao NEXT USED FG4;
ALTER PARTITION FUNCTION pf_Particao()SPLIT RANGE (30)

-- SWITCH: troca partição 1 para tabela não particionada

CREATE TABLE dbo.TesteSWITCH (
ColParticao INT NOT NULL,
ColNome VARCHAR(50) NOT NULL)
ON FG1

ALTER TABLE dbo.TesteParticao SWITCH PARTITION 1 TO dbo.TesteSWITCH
GO

SELECT * FROM dbo.TesteParticao

SELECT * FROM dbo.TesteSWITCH

-- DROP
USE master
GO

DROP DATABASE IF EXISTS BDparticao
GO