/****************
 Hands On: Ledger
*****************/

USE master
GO

DROP DATABASE IF EXISTS HandsOn
GO

CREATE DATABASE HandsOn
GO

/**************************
 Updatable Ledger
***************************/

USE HandsOn
GO

DROP TABLE If EXISTS Cliente
GO

CREATE TABLE dbo.Cliente (
ClienteID INT NOT NULL CONSTRAINT pk_Cliente PRIMARY KEY,
Nome VARCHAR(100) NOT NULL,
Email VARCHAR(100) NULL,
Credito DECIMAL(10,2) NULL)
WITH (SYSTEM_VERSIONING = ON, LEDGER = ON)
--WITH (SYSTEM_VERSIONING = ON, LEDGER = ON (APPEND_ONLY = ON))
GO


-- Restorna lista de tabelas Ledger
SELECT 
ts.[name] + '.' + t.[name] AS [ledger_table_name]
, hs.[name] + '.' + h.[name] AS [history_table_name]
, vs.[name] + '.' + v.[name] AS [ledger_view_name]
FROM sys.tables AS t
JOIN sys.tables AS h ON (h.[object_id] = t.[history_table_id])
JOIN sys.views v ON (v.[object_id] = t.[ledger_view_id])
JOIN sys.schemas ts ON (ts.[schema_id] = t.[schema_id])
JOIN sys.schemas hs ON (hs.[schema_id] = h.[schema_id])
JOIN sys.schemas vs ON (vs.[schema_id] = v.[schema_id])
GO

-- Inclui 3 linhas
INSERT dbo.Cliente VALUES (1, 'Landry', 'Landry@sqlserverexpert.com', 20000.00)
INSERT dbo.Cliente VALUES (2, 'Ana Maria', 'amaria@gmail.com', 30000.00)
INSERT dbo.Cliente VALUES (3, 'Paula Carvalho', 'pcarvalho@yahoo.com', 90)
GO

-- Retorna último ID de transação por linha
SELECT * FROM dbo.Cliente
GO

SELECT *,
ledger_start_transaction_id,ledger_end_transaction_id,
ledger_start_sequence_number,ledger_end_sequence_number
FROM dbo.Cliente
GO

-- Altera Valor de Crédito do cliente Landry
UPDATE dbo.Cliente SET Credito = 90000.00 WHERE Nome = 'Landry' -- 1160
GO

-- Retorna último ID de transação por linha
SELECT *,
ledger_start_transaction_id,ledger_end_transaction_id,
ledger_start_sequence_number,ledger_end_sequence_number
FROM dbo.Cliente
GO

SELECT * FROM dbo.MSSQL_LedgerHistoryFor_901578250
GO

SELECT * FROM dbo.Cliente_Ledger ORDER BY ledger_transaction_id
GO

/********************
 Exclui banco
*********************/
USE master
GO

ALTER DATABASE HandsOn SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

DROP DATABASE IF EXISTS HandsOn
GO

/********************************************
 Cria Banco com Ledger Habilitado
*********************************************/
CREATE DATABASE HandsOn_Ledger
WITH LEDGER = ON
GO

use HandsOn_Ledger
GO

-- Cria tabela Cliente
DROP TABLE IF EXISTS Cliente
GO

CREATE TABLE dbo.Cliente (
ClienteID INT NOT NULL CONSTRAINT pk_Cliente PRIMARY KEY,
Nome VARCHAR(100) NOT NULL,
Email VARCHAR(100) NULL,
Credito DECIMAL(10,2) NULL)
GO

-- Cria tabela Produto
DROP TABLE IF EXISTS Produto
GO

CREATE TABLE dbo.Produto (
ProdutoID INT NOT NULL CONSTRAINT pk_Produto PRIMARY KEY,
Produto VARCHAR(100) NOT NULL,
Tamanho VARCHAR(10) NULL,
PrecoUnitario DECIMAL(10,2) NULL)
GO

-- Restorna lista de tabelas Ledger

SELECT 
ts.[name] + '.' + t.[name] AS [ledger_table_name]
, hs.[name] + '.' + h.[name] AS [history_table_name]
, vs.[name] + '.' + v.[name] AS [ledger_view_name]
FROM sys.tables AS t
JOIN sys.tables AS h ON (h.[object_id] = t.[history_table_id])
JOIN sys.views v ON (v.[object_id] = t.[ledger_view_id])
JOIN sys.schemas ts ON (ts.[schema_id] = t.[schema_id])
JOIN sys.schemas hs ON (hs.[schema_id] = h.[schema_id])
JOIN sys.schemas vs ON (vs.[schema_id] = v.[schema_id])
GO

/********************
 Exclui banco
*********************/

USE master
GO

ALTER DATABASE HandsOn_Ledger SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO

DROP DATABASE IF EXISTS HandsOn_Ledger
GO