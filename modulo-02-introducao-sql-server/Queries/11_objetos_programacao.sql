/**** Views ****/

USE Aula
GO

/***********************************
 Criar tabelas
************************************/

SET NOCOUNT ON

-- Tabela Customer
DROP TABLE IF EXISTS dbo.Customer
GO

CREATE TABLE dbo.Customer (
CustomerID INT NOT NULL CONSTRAINT pk_Customer PRIMARY KEY, 
Title NVARCHAR(8) NULL, 
FirstName NVARCHAR(50) NULL, 
MiddleName NVARCHAR(50) NULL, 
LastName NVARCHAR(50) NULL,
[Name] NVARCHAR(160) NULL,
Excluido BIT NOT NULL DEFAULT (0)) 
GO

-- Carrega linhas a partir do AdventureWorks
INSERT dbo.Customer (CustomerID, Title, FirstName, MiddleName, LastName, [Name])
SELECT c.CustomerID, Title, FirstName, MiddleName, LastName, FirstName + isnull(' ' + MiddleName,'') + isnull(' ' + LastName,'') AS [Name]
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

-- Carrega linhas a partir do AdventureWorks
INSERT dbo.SalesOrderHeader (OrderDate, [Status], OnlineOrderFlag, SalesOrderNumber, CustomerID, SalesPersonID, TerritoryID, SubTotal, TaxAmt, Freight, TotalDue, Comment)
SELECT OrderDate, Status, OnlineOrderFlag, 
SalesOrderNumber, CustomerID, SalesPersonID, TerritoryID,  
SubTotal, TaxAmt, Freight, TotalDue, Comment
FROM AdventureWorks.Sales.SalesOrderHeader
GO

SET NOCOUNT OFF
/************************* FIM Prepara Hands On ******************************/

/******************************
 Hands On VIEW
*******************************/

-- Consulta completa
SELECT c.Name AS Customer, h.SalesOrderID, h.OrderDate, h.TotalDue
FROM dbo.SalesOrderHeader h
JOIN dbo.Customer c ON c.CustomerID = h.CustomerID
WHERE h.OrderDate >= '20140101' AND h.OrderDate < '20150101'
ORDER BY h.TotalDue DESC
GO

CREATE OR ALTER VIEW dbo.vw_CustomerOrder
AS
SELECT c.Name AS Customer, h.SalesOrderID, h.OrderDate, h.TotalDue
FROM dbo.SalesOrderHeader h
JOIN dbo.Customer c ON c.CustomerID = h.CustomerID
GO

SELECT Customer, SalesOrderID, OrderDate, TotalDue
FROM dbo.vw_CustomerOrder
WHERE OrderDate >= '20140101' AND OrderDate < '20150101'
ORDER BY TotalDue DESC

-- Acessado a definição original da View
SELECT OBJECT_DEFINITION(OBJECT_ID('dbo.vw_CustomerOrder','V'))

EXEC sp_helptext 'dbo.vw_CustomerOrder'

-- Exclui a View
DROP VIEW dbo.vw_CustomerOrder
GO

/***************************************
 Hands On STORED PROCEDURE
****************************************/
SELECT * FROM dbo.Customer
GO

-- Stored Procedure para exclusão lógica

CREATE OR ALTER PROC dbo.spu_Customer_DELETE
@CustomerID INT 
AS
SET NOCOUNT ON

UPDATE dbo.Customer SET Excluido = 1 
WHERE CustomerID = @CustomerID
GO

-- Exclusão lógica de um Cliente
EXEC dbo.spu_Customer_DELETE @CustomerID = 11000

SELECT * FROM dbo.Customer
WHERE CustomerID = 11000

SELECT count(*) FROM dbo.Customer -- 19.119
WHERE Excluido = 0 -- 19118

-- Exclui Procedure
DROP PROC dbo.spu_Customer_DELETE
GO

/***************************************
 Hands On FUNCTION
****************************************/

/*********************
 Função Escalar
*********************/

CREATE OR ALTER FUNCTION dbo.UltimoDiaMesAnterior (@Data date)
RETURNS date
AS 
BEGIN
  RETURN dateadd(day, - DAY(@Data), @Data)
END
GO

SELECT dbo.UltimoDiaMesAnterior(getdate()), getdate()
SELECT dbo.UltimoDiaMesAnterior('2017-01-01')

-- Exclui
DROP FUNCTION dbo.UltimoDiaMesAnterior
GO

/*********************************
 Função Table-Valued
**********************************/

CREATE OR ALTER FUNCTION dbo.fnu_CustomerOrder_Day (@Data date)
RETURNS TABLE
AS 
RETURN (
SELECT c.Name AS Customer, h.SalesOrderID, h.OrderDate, h.TotalDue
FROM dbo.SalesOrderHeader h
JOIN dbo.Customer c ON c.CustomerID = h.CustomerID
WHERE h.OrderDate >= @Data AND h.OrderDate < dateadd(dd,1,@Data))
GO

SELECT * FROM dbo.fnu_CustomerOrder_Day('20140101')

-- Excclui Função
DROP FUNCTION dbo.fnu_CustomerOrder_Day
GO

/***************************************
 Hands On TRIGGER
****************************************/

/*******************************
 Cria tabela para Auditoria
********************************/
DROP TABLE IF EXISTS dbo.AuditCustomer
GO

-- TRUNCATE TABLE dbo.AuditCustomer
CREATE TABLE dbo.AuditCustomer (
AuditCustomer_ID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
TipoAtualizacao VARCHAR(20) NOT NULL,
UserLogin VARCHAR(100) NULL,
Host VARCHAR(100) NULL,
CustomerID INT NOT NULL,
Title NVARCHAR(8) NULL,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(50) NULL,
Lastname NVARCHAR(50) NULL,
[Name] NVARCHAR(160) NULL,
Excluido BIT NULL)
GO

-- SELECT * FROM dbo.AuditCustomer

/*******************************
 Trigger INSERT/UPDATE
********************************/
-- DROP TRIGGER trg_Customer_Audit

CREATE OR ALTER TRIGGER trg_Customer_Audit
ON dbo.Customer AFTER INSERT, UPDATE
AS
SET NOCOUNT ON

DECLARE @TipoAtualizacao varchar(20)

IF EXISTS (SELECT * FROM deleted)
	SET @TipoAtualizacao = 'UPDATE'
ELSE
	SET @TipoAtualizacao = 'INSERT'

INSERT dbo.AuditCustomer
(TipoAtualizacao, UserLogin, Host, 
CustomerID, Title, FirstName, MiddleName, Lastname, [Name], Excluido)

SELECT @TipoAtualizacao,system_user AS UserLogin, host_name() AS Host,
CustomerID, Title, FirstName, MiddleName, Lastname, [Name], Excluido
FROM Inserted
GO

-- Executando alterações

SELECT * FROM dbo.Customer ORDER BY CustomerID DESC
GO

-- Provoca disparo da Trigger operação INSERT
INSERT dbo.Customer (CustomerID, Title, FirstName, MiddleName, Lastname, [Name], Excluido)
VALUES (90000,'Mr.','Jose','M.','da Silva','Jose M. da Silva',0)
GO

-- Provoca disparo da Trigger operação UPDATE
UPDATE  dbo.Customer SET Title = 'Sr.'
WHERE CustomerID = 90000
GO

-- Verifica tabela de Auditoria
SELECT * FROM dbo.Customer WHERE CustomerID = 90000
GO

SELECT * FROM dbo.AuditCustomer
GO

/******************
 Exclui Tabelas
*******************/
DROP TABLE IF EXISTS dbo.Customer
DROP TABLE IF EXISTS dbo.AuditCustomer
DROP TABLE IF EXISTS dbo.SalesOrderHeader
GO