/*************************************
 Hands On: Clustered Columnstore Index
**************************************/

USE master
GO

CREATE DATABASE DB_Columnstore
GO

ALTER DATABASE DB_Columnstore SET RECOVERY SIMPLE
GO

USE DB_Columnstore
GO

/********************************************************
 Cria Tabela e importa do banco AdventureWorks
********************************************************/
DROP TABLE IF EXISTS dbo.SalesOrderDetail_Clustered
GO

CREATE TABLE dbo.SalesOrderDetail_Clustered (
SalesOrderID INT NOT NULL,
SalesOrderDetailID INT NOT NULL,
CarrierTrackingNumber NVARCHAR(25) NULL,
OrderQty SMALLINT NOT NULL,
ProductID INT NOT NULL,
SpecialOfferID INT NOT NULL,
UnitPrice MONEY NOT NULL,
UnitPriceDiscount MONEY NOT NULL,
LineTotal NUMERIC(38, 6) NOT NULL,
rowguid UNIQUEIDENTIFIER  NOT NULL,
ModifiedDate DATETIME NOT NULL)
GO

-- Importa linhas do banco AdventureWorks
-- ATENÇÃO: esta Query poe levar até 10 minutos
INSERT dbo.SalesOrderDetail_Clustered
SELECT S1.* FROM AdventureWorks.Sales.SalesOrderDetail S1
GO 100

SELECT * INTO dbo.SalesOrderDetail_ColumstoreClustered
FROM dbo.SalesOrderDetail_Clustered
GO

/**********************************
 Cria Indice Btree Custered
***********************************/
CREATE CLUSTERED INDEX ix_SalesOrderDetail_Clustered 
ON dbo.SalesOrderDetail_Clustered (SalesOrderID,SalesOrderDetailID)
GO

/**********************************
 Cria Indice Columnstore Custered
***********************************/
CREATE CLUSTERED COLUMNSTORE INDEX ixc_SalesOrderDetail_ColumstoreClustered
ON dbo.SalesOrderDetail_ColumstoreClustered 
GO

/**********************************
 Comprando a ocupação
***********************************/
EXEC sp_spaceused 'dbo.SalesOrderDetail_Clustered'
EXEC sp_spaceused 'dbo.SalesOrderDetail_ColumstoreClustered'

/*
name									rows		reserved	data		index_size	unused
SalesOrderDetail_Clustered				12131700    1276184 KB	1.272.096 KB KB	3984 KB		112 KB

SalesOrderDetail_ColumstoreClustered	12131700     129864 KB	  128.072 KB KB	    0 KB	 88 KB
*/

-- Exclui banco

USE master
GO
DROP DATABASE IF EXISTS DB_Columnstore
GO