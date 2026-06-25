/************************************************************
 Hands On:  Persistência dos Dados em Memory-Optimized Tables
*************************************************************/

USE master
GO

-- DROP DATABASE MemoryDB

CREATE DATABASE MemoryDB
ON (name = 'MemoryDB', filename = 'C:\MSSQL_Data\MemoryDB.mdf', size = 100MB, filegrowth = 50MB)
LOG ON (name = 'MemoryDB_log', filename = 'C:\MSSQL_Data\MemoryDB_log.ldf', size = 50MB, filegrowth = 50MB)
GO

ALTER DATABASE MemoryDB SET RECOVERY simple
GO

-- Preparando o Banco para In-Memory OLTP

ALTER DATABASE MemoryDB
ADD FILEGROUP mem_data CONTAINS MEMORY_OPTIMIZED_DATA
GO

ALTER DATABASE MemoryDB
ADD FILE (NAME = 'MemoryDB_MemData', FILENAME = 'C:\MSSQL_Data\MemoryDB_Data')
TO FILEGROUP mem_data
GO

/*********************************************
 Criando tabela SEM persistência dos Dados
**********************************************/

DROP TABLE IF EXISTS MemoryDB.dbo.Venda_Schema
GO

CREATE TABLE MemoryDB.dbo.Venda_Schema
(Venda_ID INT NOT NULL,
DataVenda DATETIME NOT NULL,
Cliente_ID INT NULL,
Vendedor_ID INT NULL,
Valor_Total DECIMAL(12,2) NULL
PRIMARY KEY NONCLUSTERED (Venda_ID))
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY)
GO


INSERT MemoryDB.dbo.Venda_Schema 
(Venda_ID,DataVenda,Cliente_ID,Vendedor_ID,Valor_Total)
VALUES 
(1001,getdate(),11,21,1500.00),
(1002,getdate(),12,22,420.00),
(1003,getdate(),13,23,12400.00)
GO

SELECT * FROM MemoryDB.dbo.Venda_Schema
GO

-- Coloca o banco em Off Line para verificar a perda dos dados

USE master
GO

ALTER DATABASE MemoryDB SET OFFLINE WITH ROLLBACK IMMEDIATE
ALTER DATABASE MemoryDB SET ONLINE
GO

SELECT * FROM MemoryDB.dbo.Venda_Schema
GO
-- Zero linhas

/*********************************************
 Criando tabela COM persistência dos Dados
**********************************************/
DROP TABLE IF EXISTS MemoryDB.dbo.Venda_Data
GO

CREATE TABLE MemoryDB.dbo.Venda_Data
(Venda_ID INT NOT NULL,
DataVenda DATETIME NOT NULL,
Cliente_ID INT NULL,
Vendedor_ID INT NULL,
Valor_Total DECIMAL(12,2) NULL
PRIMARY KEY NONCLUSTERED (Venda_ID))
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA)
GO

INSERT MemoryDB.dbo.Venda_Data 
(Venda_ID,DataVenda,Cliente_ID,Vendedor_ID,Valor_Total)
VALUES 
(1001,getdate(),11,21,1500.00),
(1002,getdate(),12,22,420.00),
(1003,getdate(),13,23,12400.00)
GO

SELECT * FROM MemoryDB.dbo.Venda_Data

-- Coloca o banco em Off Line para verificar a perda dos dados

USE master
GO

ALTER DATABASE MemoryDB SET OFFLINE WITH ROLLBACK IMMEDIATE
ALTER DATABASE MemoryDB SET ONLINE
GO

SELECT * FROM MemoryDB.dbo.Venda_Data WHERE Venda_ID = 1002
GO

-- Lista tabelas Memory-Optimized
SELECT b.[name] AS Tabela, a.*
FROM MemoryDB.sys.dm_db_xtp_table_memory_stats a
JOIN MemoryDB.sys.tables b ON a.[object_id] = b.[object_id]
GO

-- Estatísticas de uso dos índices em tabelas Memory-Optimized

SELECT b.[name] AS Tabela, c.[name] AS Indices,a.*
FROM MemoryDB.sys.dm_db_xtp_index_stats a
JOIN MemoryDB.sys.tables b ON a.[object_id] = b.[object_id]
JOIN MemoryDB.sys.indexes c ON a.[object_id] = c.[object_id] and a.index_id = c.index_id
WHERE a.index_id > 0
GO

-- Manter o banco pois será utilizado nas aulas seguintes