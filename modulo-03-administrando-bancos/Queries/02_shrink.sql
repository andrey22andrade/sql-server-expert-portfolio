/******
 Shrink
*******/

USE master
GO

CREATE DATABASE DB_Teste
GO
ALTER DATABASE DB_Teste SET RECOVERY FULL
GO

--  Create tabela no banco DB_Teste
DROP TABLE IF EXISTS DB_Teste.dbo.tb_Teste
GO
CREATE TABLE DB_Teste.dbo.tb_Teste ( 
tb_Teste_ID INT IDENTITY CONSTRAINT pk_tb_Teste PRIMARY KEY,
ColunaGrande NCHAR(2000),
ColunaBigint BIGINT)
GO

SET NOCOUNT ON

-- Inclui 100.000 linhas
INSERT DB_Teste.dbo.tb_Teste (ColunaGrande,ColunaBigint)
VALUES('Teste',12345)
GO 100000

USE DB_Teste
GO

SELECT name AS Name, size * 8 /1024. AS Tamanho_MB,  
FILEPROPERTY(name,'SpaceUsed') * 8 /1024. AS Espaco_Utilizado_MB,
CAST(FILEPROPERTY(name,'SpaceUsed') AS DECIMAL(10,4))
/ CAST(size AS DECIMAL(10,4)) * 100 AS Percentual_Utilizado
FROM sys.database_files
/*
Name			Tamanho_MB	Espaco_Utilizado_MB	Percentual_Utilizado
DB_TesteLog		456.000000	395.812500			86.800986842105200
DB_TesteLog_log	328.000000	214.312500			65.339176829268200
*/

-- Reduz mas mantém 10% de espaço livre
DBCC SHRINKDATABASE('DB_Teste', 10 )

-- Exclui metade das linhas
DELETE top(50000) DB_Teste.dbo.tb_Teste


USE DB_TesteLog
GO

DBCC SHRINKFILE (N'DB_Teste' , 250)

-- Exclui banco
USE master
GO

DROP DATABASE IF exists DB_Teste
GO