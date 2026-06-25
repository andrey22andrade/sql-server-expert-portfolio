/****************************************************
 Hands On: Memory-Optimized Tables x Disk-Base Tables
*****************************************************/

USE master
GO

-- DROP DATABASE MemoryDB
CREATE DATABASE MemoryDB
ON (name = 'MemoryDB', filename = 'C:\MSSQL_Data\MemoryDB.mdf', size = 100MB, filegrowth = 50MB),
FILEGROUP mem_data CONTAINS MEMORY_OPTIMIZED_DATA
(NAME = 'MemoryDB_MemData', FILENAME = 'C:\MSSQL_Data\MemoryDB_Data')
LOG ON (name = 'MemoryDB_log', filename = 'C:\MSSQL_Data\MemoryDB_log.ldf', size = 50MB, filegrowth = 50MB)
GO

ALTER DATABASE MemoryDB SET RECOVERY simple
GO

/***********************************
 Cenário 1
 - Disk-Base Table
************************************/
DROP TABLE IF EXISTS MemoryDB.dbo.Produto
GO

CREATE TABLE MemoryDB.dbo.Produto (
ProductID INT NOT NULL IDENTITY PRIMARY KEY,
Product_Name VARCHAR(50) NOT NULL,
ProductNumber VARCHAR(25) NULL,
Size VARCHAR(5) NULL,
Color VARCHAR(15) NULL,
ListPrice MONEY NULL)
GO

/***************************
 Utilizar SQLQueryStress
 Interations: 50000
 Threads: 4
****************************/
INSERT MemoryDB.dbo.Produto (Product_Name, ProductNumber, Size, Color, ListPrice )
VALUES ('Sport-100 Helmet, Red','HL-U509-R','50','Red',34.99)

INSERT MemoryDB.dbo.Produto (Product_Name, ProductNumber, Size, Color, ListPrice )
VALUES ('Fender Set - Mountain','FE-6654','80','Blue',21.98)

INSERT MemoryDB.dbo.Produto (Product_Name, ProductNumber, Size, Color, ListPrice )
VALUES ('Road-150 Red, 48','BK-R93R-48','48','Red',3578.27)
GO

-- Tempo 01:52


/**********************************
 Cenário 2
 - Tabela Memory-Optimized
***********************************/
DROP TABLE IF EXISTS MemoryDB.dbo.Produto_InMemory
GO

CREATE TABLE MemoryDB.dbo.Produto_InMemory (
ProductID INT NOT NULL identity,
Product_Name VARCHAR(50) NOT NULL,
ProductNumber VARCHAR(25) NULL,
Size VARCHAR(5) NULL,
Color VARCHAR(15) NULL,
ListPrice MONEY NULL,
PRIMARY KEY NONCLUSTERED HASH (ProductID) WITH (BUCKET_COUNT = 1000000))
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY)
GO

/***************************
 Utilizar SQLQueryStress
 Interations: 50000
 Threads: 4
****************************/
INSERT MemoryDB.dbo.Produto_InMemory (Product_Name, ProductNumber, Size, Color, ListPrice )
VALUES ('Sport-100 Helmet, Red','HL-U509-R','50','Red',34.99)

INSERT MemoryDB.dbo.Produto_InMemory (Product_Name, ProductNumber, Size, Color, ListPrice )
VALUES ('Fender Set - Mountain','FE-6654','80','Blue',21.98)

INSERT MemoryDB.dbo.Produto_InMemory (Product_Name, ProductNumber, Size, Color, ListPrice )
VALUES ('Road-150 Red, 48','BK-R93R-48','48','Red',3578.27)
GO

-- Tempo 01:02


/****************************************
 Cenário 3
 - Tabela Memory-Optimized com
   Natively Compiled Stored Procedure
*****************************************/

USE MemoryDB
GO

DROP TABLE IF EXISTS MemoryDB.dbo.Produto_InMemory
GO

CREATE TABLE MemoryDB.dbo.Produto_InMemory (
ProductID INT NOT NULL IDENTITY,
Product_Name varchar(50) NOT NULL,
ProductNumber varchar(25) NULL,
Size VARCHAR(5) NULL,
Color VARCHAR(15) NULL,
ListPrice money NULL,
PRIMARY KEY NONCLUSTERED HASH (ProductID) WITH (BUCKET_COUNT = 1000000))
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_ONLY)
GO

DROP PROCEDURE IF EXISTS dbo.Insert_Produto_InMemory
GO

CREATE PROCEDURE dbo.Insert_Produto_InMemory
WITH NATIVE_COMPILATION, SCHEMABINDING, EXECUTE AS OWNER
AS
BEGIN ATOMIC WITH (TRANSACTION ISOLATION LEVEL = SNAPSHOT, LANGUAGE = 'us_english')


INSERT dbo.Produto_InMemory (Product_Name, ProductNumber, Size, Color, ListPrice )
VALUES ('Sport-100 Helmet, Red','HL-U509-R','50','Red',34.99)

INSERT dbo.Produto_InMemory (Product_Name, ProductNumber, Size, Color, ListPrice )
VALUES ('Fender Set - Mountain','FE-6654','80','Blue',21.98)

INSERT dbo.Produto_InMemory (Product_Name, ProductNumber, Size, Color, ListPrice )
VALUES ('Road-150 Red, 48','BK-R93R-48','48','Red',3578.27)

END
GO

/***************************
 Utilizar SQLQueryStress
 Interations: 50000
 Threads: 4
****************************/
EXEC dbo.Insert_Produto_InMemory
GO
-- Tempo 00:31

/*************************************
Resumo

Teste					Tempo Total
-----------------------------------
Tabela Disk-Base		01:52
Tabela Memory-Optimized	01:02
Natively Compiled SP	00:31
-----------------------------------