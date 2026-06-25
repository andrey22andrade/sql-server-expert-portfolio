/************************************************
 Hands On: Migrando para Tabelas Memory-Optimized
*************************************************/

USE MemoryDB
GO

DROP TABLE IF EXISTS dbo.Venda
GO

CREATE TABLE dbo.Venda
(Venda_ID INT NOT NULL,
DataVenda DATETIME NOT NULL,
Cliente_ID INT NULL,
Vendedor_ID INT NULL,
Valor_Total DECIMAL(12,2) NULL)
GO

-- inclui 10.000 linhas

DECLARE @i INT = 1
WHILE @i <= 10000 BEGIN
	INSERT dbo.Venda (Venda_ID,DataVenda,Cliente_ID,Vendedor_ID,Valor_Total)
	VALUES (@i,getdate(),11,21,10.00 + @i)
	SET @i += 1
END
GO

SELECT count(*) FROM dbo.Venda
GO

SELECT * FROM dbo.Venda
SELECT * FROM dbo.Venda_old
GO

/***************************************************************
 Hash Bucket
 - Tamanho do índice hash está relacionado ao valor do Bucket!
 - [Tamanho do ídice] = 8 * [bucket count] (Bytes)
 - Recomendado ter de 1x a 2x a quantidade de valores distintos.

 https://learn.microsoft.com/en-us/sql/relational-databases/sql-server-index-design-guide?view=sql-server-ver16#hash_index
****************************************************************/

-- Valor ideal
SELECT POWER(2,CEILING( LOG( COUNT( 0)) / LOG( 2))) AS 'BUCKET_COUNT'
FROM (SELECT DISTINCT Venda_ID FROM Venda) T
GO

-- Alterando o Bucket
ALTER TABLE dbo.Venda
ALTER INDEX imPK_Venda_Venda_ID
REBUILD WITH (BUCKET_COUNT=67108864)  
GO

-- Lista tabelas Memory-Optimized
SELECT b.[name] AS Tabela, a.*
FROM MemoryDB.sys.dm_db_xtp_table_memory_stats a
JOIN MemoryDB.sys.tables b ON a.[object_id] = b.[object_id]
GO

-- Exclui Banco
USE master
GO

ALTER DATABASE MemoryDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE
DROP DATABASE IF EXISTS MemoryDB
GO