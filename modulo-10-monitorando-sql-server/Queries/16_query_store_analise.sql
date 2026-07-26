/********************************************
 Hands ON: Query Store - Analisando ConsultAS
*********************************************/

USE mASter
GO

/***********************************
 Prepara Hands ON
************************************/

CREATE DATABASE DB_HandsOn
GO
ALTER DATABASE DB_HandsOn SET RECOVERY simple
GO

USE DB_HandsOn
GO

-- Tabela Customer
DROP TABLE IF EXISTS dbo.Customer
GO
CREATE TABLE dbo.Customer (
CustomerID INT NOT NULL CONSTRAINT pk_Customer PRIMARY KEY, 
Title NVARCHAR(8) NULL, 
FirstName NVARCHAR(50) NULL, 
MiddleName NVARCHAR(50) NULL, 
LAStName NVARCHAR(50) NULL,
[Name] NVARCHAR(160) NULL) 
GO

-- Carrega linhAS a partir do AdventureWorks
SET NOCOUNT ON
INSERT dbo.Customer (CustomerID, Title, FirstName, MiddleName, LAStName, [Name])
SELECT c.CustomerID, Title, FirstName, MiddleName, LAStName, FirstName + ISNULL(' ' + MiddleName,'') + isnull(' ' + LAStName,'') AS [Name]
FROM AdventureWorks.Sales.Customer c
JOIN AdventureWorks.Person.Person p ON p.BusinessEntityID = c.PersonID
GO

-- Tabela SalesOrderHeader
DROP TABLE IF EXISTS dbo.SalesOrderHeader
GO
CREATE TABLE dbo.SalesOrderHeader(
SalesOrderID INT NOT NULL IDENTITY CONSTRAINT pk_SalesOrderHeader PRIMARY KEY,
OrderDate DATETIME NOT NULL,
Status TINYINT NOT NULL,
OnlineOrderFlag BIT NOT NULL,
SalesOrderNumber CHAR(200) NOT NULL,
CustomerID INT NOT NULL,
SalesPersonID INT NULL,
TerritoryID INT NULL,
SubTotal MONEY NOT NULL,
TaxAmt MONEY NOT NULL,
Freight MONEY NOT NULL,
TotalDue MONEY NOT NULL,
Comment NVARCHAR(128) NULL)
GO

-- Alimenta tabela com 6.293.000 linhAS
SET NOCOUNT ON

INSERT dbo.SalesOrderHeader (OrderDate, [Status], OnlineOrderFlag, SalesOrderNumber, CustomerID, SalesPersonID, TerritoryID, SubTotal, TaxAmt, Freight, TotalDue, Comment)
SELECT OrderDate, Status, OnlineOrderFlag, 
SalesOrderNumber, CustomerID, SalesPersonID, TerritoryID,  
SubTotal, TaxAmt, Freight, TotalDue, Comment
FROM AdventureWorks.Sales.SalesOrderHeader
GO 200
-- Leva 1 minuto

SET NOCOUNT OFF

-- SELECT COUNT(*) AS QtdLinhAS FROM dbo.SalesOrderHeader
/************************* FIM Prepara Hands ON ******************************/

/***************************************
 Limpar os dados no Query Store
****************************************/
ALTER DATABASE DB_HandsOn SET QUERY_STORE CLEAR ALL

/******************************************************************
 Consulta simples não vai para o Query Store configuração padrão
*******************************************************************/
SELECT * FROM dbo.Customer WHERE CustomerID = 11000

/********************************
 Executar antes de criar índice
*********************************/
SELECT c.Name AS Customer, COUNT(*) AS Sales_Qty, SUM(h.TotalDue) AS Total
FROM dbo.SalesOrderHeader h
JOIN dbo.Customer c ON c.CustomerID = h.CustomerID
WHERE h.OrderDate >= '20140101' and h.OrderDate < '20150101'
GROUP BY c.Name
ORDER BY Total desc

-- Cria índice para alterar o plano de execução
CREATE NONCLUSTERED INDEX ix_SalesOrderHeader_OrderDate
ON dbo.SalesOrderHeader (OrderDate)
INCLUDE (CustomerID,TotalDue)

-- Para limpar dados de consulta específica
EXEC sp_query_store_remove_query @query_id = 7

/********************************
 Executar após criar índice
*********************************/
SELECT c.Name AS Customer, COUNT(*) AS Sales_Qty, SUM(h.TotalDue) AS Total
FROM dbo.SalesOrderHeader h
JOIN dbo.Customer c ON c.CustomerID = h.CustomerID
WHERE h.OrderDate >= '20140101' and h.OrderDate < '20150101'
GROUP BY c.Name
ORDER BY Total desc


/*************************
 Exclui o banco
**************************/
USE master
GO

ALTER DATABASE DB_HandsOn SET READ_ONLY WITH ROLLBACK IMMEDIATE
GO

DROP DATABASE IF EXISTS DB_HandsOn
GO
