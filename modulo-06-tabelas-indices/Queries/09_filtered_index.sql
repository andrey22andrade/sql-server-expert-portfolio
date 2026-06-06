/*************************
 Hands On - Filtered Index
**************************/

USE Aula
GO

/*****************************************
 Cria tabela Product para Hands On
******************************************/
DROP TABLE IF EXISTS dbo.Product
GO

CREATE TABLE dbo.Product(
ProductID INT NOT NULL PRIMARY KEY,
Product_Name VARCHAR(150) NOT NULL,
ProductNumber CHAR(20) NOT NULL,
Color CHAR(15) NULL,
ListPrice MONEY NOT NULL,
Size CHAR(5) NULL,
DaysToManufacture INT NOT NULL,
ProductLine CHAR(2) NULL,
SellStartDate DATETIME NULL,
Flag_Discontinued BIT NOT NULL)
GO

-- Carrega tabela com linhas
DECLARE @i INT = 0

WHILE @i <= 20000000 BEGIN

	INSERT dbo.Product
	SELECT p.ProductID + @i AS ProductID, p.[Name] + isnull(' - ' + m.[Name],'') AS Product_Name,
	ProductNumber, Color, ListPrice, Size, DaysToManufacture, ProductLine, SellStartDate,
	CASE WHEN @i <= 5000000 THEN 1 ELSE 0 END AS Flag_Discontinued
	FROM AdventureWorks.Production.Product p
	JOIN AdventureWorks.Production.ProductModel m ON m.ProductModelID = p.ProductModelID

	SET @i += 1000
END
GO

-- Tempo de execução +- 1 min

SELECT count(*) FROM dbo.Product -- 5.900.295 linhas

-- Produtos que foram descontinuados são marcados com Flag_Discontinued = 1
SELECT Flag_Discontinued,count(*) AS QtdLinhas
FROM dbo.Product
GROUP BY Flag_Discontinued 
ORDER BY 1

/*
Flag_Discontinued	QtdLinhas
0					4.425.000
1					1.475.295
*/

SET STATISTICS IO ON
SET STATISTICS IO OFF

CREATE INDEX ix_Product ON dbo.Product (ProductNumber,Flag_Discontinued)
INCLUDE (Product_Name,Color,ListPrice)

CREATE INDEX ix_Product_Filtered ON dbo.Product (ProductNumber,Flag_Discontinued)
INCLUDE (Product_Name,Color,ListPrice)
WHERE Flag_Discontinued = 0


SELECT i.name AS Indice, SUM(s.used_page_count) * 8 AS Indice_KB
FROM sys.dm_db_partition_stats s 
JOIN sys.indexes i ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id
WHERE s.[object_id] = object_id('dbo.Product')
and i.name like 'ix_Product%'
GROUP BY i.name
/*
Indice				Indice_KB
ix_Product			570088
ix_Product_Filtered	427552
*/

SELECT ProductID, Product_Name, Color, ListPrice
FROM dbo.Product
WHERE Flag_Discontinued = 0
-- Table 'Product'. Scan count 1, logical reads 71257
-- Table 'Product'. Scan count 1, logical reads 53441


-- Exclui tabela
DROP TABLE IF EXISTS dbo.Product
GO