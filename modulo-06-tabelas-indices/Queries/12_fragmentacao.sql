/****************************************************
 Hands On: PK Clustered sequencial ou não sequencial?
*****************************************************/ 

USE Aula
GO

/******************************************
 Cria tabela com PK sequencial IDENTITY
*******************************************/
DROP TABLE IF EXISTS dbo.Cliente_PkSequencial
GO

CREATE TABLE dbo.Cliente_PkSequencial (
Cliente_ID INT NOT NULL IDENTITY CONSTRAINT pk_Cliente_PkSequencial PRIMARY KEY,
CPF VARCHAR(14) NOT NULL,
Nome VARCHAR(50) NOT NULL,
DataAniversario DATE NOT NULL,
Obs CHAR(3000) NOT NULL)
GO

/******************************************
 Cria tabela com PK não sequencial CPF
*******************************************/
DROP TABLE IF EXISTS dbo.Cliente_PkCPF
GO

CREATE TABLE dbo.Cliente_PkCPF (
Cliente_ID INT NOT NULL IDENTITY,
CPF VARCHAR(14) NOT NULL CONSTRAINT pk_Cliente_PkCPF PRIMARY KEY,
Nome VARCHAR(50) NOT NULL,
DataAniversario DATE NOT NULL,
Obs CHAR(3000) NOT NULL)
GO

/************************************
 Inclui 80 mil em ambas as tabelas
*************************************/
-- Inclui 80 mil linhas em PK sequencial IDENTITY (14 segundos)
DECLARE @i int = 20000

WHILE @i <= 100000 BEGIN
	INSERT dbo.Cliente_PkSequencial (CPF, Nome, DataAniversario, Obs)
	VALUES (ltrim(str(cast(rand(@i)*1000000000 as int))),'Teste Fragmentação',getdate(),'Ocupa 3000 bytes')

	SET @i += 1
END
GO

-- Inclui 80 mil linhas em PK Não sequencial CPF (32 segundos)
DECLARE @i int = 20000

WHILE @i <= 100000 BEGIN
	INSERT dbo.Cliente_PkCPF (CPF, Nome, DataAniversario, Obs)
	VALUES (ltrim(str(cast(rand(@i)*1000000000 as int))),'Teste Fragmentação',getdate(),'Ocupa 3000 bytes')

	SET @i += 1
END
GO

/********************************************
 Analisa Fragmentação
*********************************************/

SELECT a.index_type_desc, a.index_level ,a.page_count,
a.record_count, a.avg_page_space_used_in_percent,
a.forwarded_record_count,
a.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(),
OBJECT_ID('dbo.Cliente_PkSequencial', 'U'),NULL,NULL,'DETAILED') AS a
-- Fragmentação Externa: 0.37%

SELECT a.index_type_desc, a.index_level ,a.page_count,
a.record_count, a.avg_page_space_used_in_percent,
a.forwarded_record_count,
a.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(),
OBJECT_ID('dbo.Cliente_PkCPF', 'U'),NULL,NULL,'DETAILED') AS a
-- Fragmentação Externa: 80.00%

ALTER INDEX pk_Cliente_PkCPF ON dbo.Cliente_PkCPF REBUILD WITH (FILLFACTOR = 60)
-- Fragmentação Externa: 0.01%

DECLARE @i INT = 100001

WHILE @i <= 101000 BEGIN
	INSERT dbo.Cliente_PkCPF (CPF, Nome, DataAniversario, Obs)
	VALUES (ltrim(str(cast(rand(@i)*1000000000 as int))),'Teste Fragmentação',getdate(),'Ocupa 3000 bytes')

	SET @i += 1
END
GO


-- Exclui tabelas
DROP TABLE IF EXISTS dbo.Cliente_PkSequencial
DROP TABLE IF EXISTS dbo.Cliente_PkCPF
GO
