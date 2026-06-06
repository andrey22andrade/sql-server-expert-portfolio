/******************************
 Hands On: Compressão de Dados
******************************/

USE Aula
GO

/**************************
 Tabela Sem Compressão
***************************/
DROP TABLE IF EXISTS dbo.TB_Teste
GO

CREATE TABLE dbo.TB_Teste ( 
ID INT IDENTITY NOT NULL, 
String CHAR(100) NULL) 
GO

SET NOCOUNT ON
GO

INSERT dbo.TB_Teste 
SELECT ISNULL(Title,'') + ISNULL(FirstName,'B') FROM AdventureWorks.Person.Person 
UNION
SELECT ISNULL(FirstName,'B') + ISNULL(MiddleName,'') FROM AdventureWorks.Person.Person
UNION
SELECT ISNULL(FirstName,'B') + ISNULL(MiddleName,'') + ISNULL(LastName,'') FROM AdventureWorks.Person.Person
UNION
SELECT ISNULL(Title,'') + ISNULL(FirstName,'B') + ISNULL(MiddleName,'') + ISNULL(LastName,'') FROM AdventureWorks.Person.Person 
GO 60

INSERT dbo.TB_Teste VALUES ('Valor Pesquisa')

SELECT * INTO dbo.TB_Teste_ROW FROM dbo.TB_Teste
SELECT * INTO dbo.TB_Teste_PAGE FROM dbo.TB_Teste
GO

SELECT COUNT(*) FROM dbo.TB_Teste -- 1.718.941 linhas
SELECT COUNT(*) FROM dbo.TB_Teste_ROW -- 1.718.941 linhas
SELECT COUNT(*) FROM dbo.TB_Teste_PAGE -- 1.718.941 linhas
GO

/***********************************************
 Teste Sem Compressão
************************************************/

SET STATISTICS IO ON

ALTER TABLE dbo.TB_Teste REBUILD WITH ( DATA_COMPRESSION = NONE ) 
CREATE INDEX ix_TB_Teste ON dbo.TB_Teste (String)
GO

SELECT * FROM dbo.TB_Teste 
GO
-- Paralelismo: Table 'TB_Teste'. Scan count 1, logical reads 24211

SELECT * FROM dbo.TB_Teste 
WHERE String = 'Valor Pesquisa'
GO

-- Table 'TB_Teste'. Scan count 1, logical reads 5

/*************************************
 Compressão de LINHA
**************************************/
ALTER TABLE dbo.TB_Teste_ROW REBUILD WITH ( DATA_COMPRESSION = ROW ) 
CREATE INDEX ix_TB_Teste_ROW ON dbo.TB_Teste_ROW (String) WITH ( DATA_COMPRESSION = ROW )

SELECT * FROM dbo.TB_Teste_ROW 
GO
-- Table 'TB_Teste'. Scan count 1, logical reads 4783

SELECT * FROM dbo.TB_Teste_ROW 
WHERE String = 'Valor Pesquisa'
GO
-- Table 'TB_Teste'. Scan count 1, logical reads 5

/*************************************
 Compressão de PAGINA
**************************************/
ALTER TABLE dbo.TB_Teste_PAGE REBUILD WITH ( DATA_COMPRESSION = PAGE ) 
CREATE INDEX ix_TB_Teste_PAGE ON dbo.TB_Teste_PAGE (String) WITH ( DATA_COMPRESSION = PAGE )
GO

SELECT * FROM dbo.TB_Teste_PAGE 
GO
-- Table 'TB_Teste'. Scan count 1, logical reads 4294

SELECT * FROM dbo.TB_Teste_PAGE 
WHERE String = 'Valor Pesquisa'
GO
-- Table 'TB_Teste_PAGE'. Scan count 1, logical reads 4

/*
------------------------------------------
				Compressão	Scan	Seek
------------------------------------------
TB_Teste		   -		24.211	 5
TB_Teste_ROW	  ROW		 4.783	 5
TB_Teste_PAGE	  PAGE		 4.294	 4
------------------------------------------
*/

-- Exclui tabelas
DROP TABLE IF EXISTS dbo.TB_Teste
DROP TABLE IF EXISTS dbo.TB_Teste_ROW
DROP TABLE IF EXISTS dbo.TB_Teste_PAGE
GO