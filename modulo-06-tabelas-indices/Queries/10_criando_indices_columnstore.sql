/************************************
 Hands On: Criando Indice Columnstore
*************************************/ 

USE master
GO

CREATE DATABASE DB_IndiceColumnstore
GO

ALTER DATABASE DB_IndiceColumnstore SET RECOVERY SIMPLE
GO

use DB_IndiceColumnstore
GO

/**********************************************
 Cria Tabela e importa do banco AdventureWorks
 - Indice Btree
***********************************************/
DROP TABLE IF EXISTS dbo.SalesOrderDetail
GO

CREATE TABLE dbo.SalesOrderDetail(
SalesOrderID INT NOT NULL,
SalesOrderDetailID INT NOT NULL,
CarrierTrackingNumber NVARCHAR(25) NULL,
OrderQty SMALLINT NOT NULL,
ProductID INT NOT NULL,
SpecialOfferID INT NOT NULL,
UnitPrice MONEY NOT NULL,
UnitPriceDiscount MONEY NOT NULL,
LineTotal NUMERIC(38, 6) NOT NULL,
rowguid UNIQUEIDENTIFIER NOT NULL,
ModifiedDate DATETIME NOT NULL)
GO

-- Importa linhas do banco AdventureWorks
-- ATENÇÃO: esta Query poe levar até 10 minutos
INSERT INTO dbo.SalesOrderDetail
SELECT S1.* FROM AdventureWorks.Sales.SalesOrderDetail S1
GO 100

/**********************************************
 Cria Tabela e importa do banco AdventureWorks
 -- Indice Columnstore
***********************************************/
DROP TABLE IF EXISTS dbo.SalesOrderDetail_Column
GO

CREATE TABLE dbo.SalesOrderDetail_Column(
SalesOrderID INT NOT NULL,
SalesOrderDetailID INT NOT NULL,
CarrierTrackingNumber NVARCHAR(25) NULL,
OrderQty SMALLINT NOT NULL,
ProductID INT NOT NULL,
SpecialOfferID INT NOT NULL,
UnitPrice MONEY NOT NULL,
UnitPriceDiscount MONEY NOT NULL,
LineTotal NUMERIC(38, 6) NOT NULL,
rowguid UNIQUEIDENTIFIER NOT NULL,
ModifiedDate DATETIME NOT NULL)
GO

-- Importa linhas do banco AdventureWorks
-- ATENÇÃO: esta Query poe levar até 10 minutos
INSERT INTO dbo.SalesOrderDetail_Column
SELECT S1.* FROM AdventureWorks.Sales.SalesOrderDetail S1
GO 100

/*****************************************************************************/

/*******************************
 Cria indice Btree
********************************/
-- DROP INDEX SalesOrderDetail.ix_SalesOrderDetail
CREATE INDEX ix_SalesOrderDetail ON dbo.SalesOrderDetail (ProductID)
INCLUDE (UnitPrice, OrderQty)
GO

/****************************************
 Cria indice Columnstore
*****************************************/
-- DROP INDEX SalesOrderDetail_Column.ix_SalesOrderDetail_Column_ProductID
CREATE NONCLUSTERED COLUMNSTORE INDEX ix_SalesOrderDetail_Column_ProductID
ON SalesOrderDetail_Column (ProductID,UnitPrice, OrderQty)
GO

/****************************
 Comparando o Desempenho
*****************************/
SET STATISTICS IO ON
GO

SELECT ProductID, SUM(UnitPrice) SumUnitPrice, AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty
FROM dbo.SalesOrderDetail
GROUP BY ProductID 
ORDER BY ProductID
GO
-- Table 'SalesOrderDetail'. Scan count 4, logical reads 42.529

SELECT ProductID, SUM(UnitPrice) SumUnitPrice, AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty
FROM dbo.SalesOrderDetail_Column
GROUP BY ProductID 
ORDER BY ProductID
GO
-- Table 'SalesOrderDetail_Column'. Scan count 4, lob logical reads 11.855, lob physical reads 17
-- Table 'SalesOrderDetail_Column'. Segment reads 13, segment skipped 0.

-- Executar junto
-- 92%
SELECT ProductID, SUM(UnitPrice) SumUnitPrice, AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty
FROM dbo.SalesOrderDetail
GROUP BY ProductID 
ORDER BY ProductID
GO

-- 8%
SELECT ProductID, SUM(UnitPrice) SumUnitPrice, AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty
FROM dbo.SalesOrderDetail_Column
GROUP BY ProductID 
ORDER BY ProductID
GO

USE master
GO

DROP DATABASE DB_IndiceColumnstore
GO