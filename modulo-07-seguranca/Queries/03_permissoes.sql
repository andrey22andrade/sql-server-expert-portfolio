/********************
 Hands On: Permissões
*********************/

USE master
GO

/***************************************
 Permissões nível Instância
 https://learn.microsoft.com/en-us/sql/t-sql/statements/grant-server-permissions-transact-sql?view=sql-server-ver16
****************************************/

-- Cria Login para Hands On
CREATE LOGIN Teste WITH PASSWORD=N'Pa$$w0rd', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF

GRANT CONNECT ANY DATABASE TO Teste
REVOKE CONNECT ANY DATABASE TO Teste


SELECT pr.principal_id, pr.name AS Login_SrvRole, pr.type_desc AS Tipo,   
pe.state_desc AS [Status], pe.permission_name AS Permissao
FROM sys.server_principals AS pr   
JOIN sys.server_permissions AS pe ON pe.grantee_principal_id = pr.principal_id
--WHERE pr.name = 'Teste'
ORDER BY Login_SrvRole, Permissao


/*****************************************
 Permissões em Bancos de Dados
******************************************/
DROP DATABASE IF EXISTS HandsOn
GO

CREATE DATABASE HandsOn
GO

ALTER DATABASE HandsOn SET RECOVERY simple
GO

USE HandsOn
GO

/********************************************
 Cria Objetos para Hands On

 Tabelas:
 - dbo.Cliente
 - Vendas.tb_Venda
 - Vendas.tb_Venda_Detalhe

 View: Vendas.vw_Venda

 Stored Procedure: 
 - Vendas.spu_Venda
 - Vendas.spu_Venda_Detalhe
********************************************/
DROP TABLE IF EXISTS dbo.Cliente
GO

CREATE TABLE dbo.Cliente (
Cliente_ID INT NOT NULL CONSTRAINT pk_Cliente PRIMARY KEY,
Nome varchar(100) NOT NULL,
Telefone varchar(50) NULL)
GO

INSERT dbo.Cliente (Cliente_ID,Nome,Telefone)
SELECT BusinessEntityID AS Cliente_ID,
FirstName + ISNULL(' ' + MiddleName,'') + ISNULL(' ' + LastName,'') AS Nome,
PhoneNumber AS Telefone
FROM AdventureWorks.Sales.vSalesPerson
GO

CREATE SCHEMA Vendas
GO

SELECT * into Vendas.tb_Venda FROM AdventureWorks.Sales.SalesOrderHeader
SELECT * into Vendas.tb_Venda_Detalhe FROM AdventureWorks.Sales.SalesOrderDetail
GO

CREATE VIEW Vendas.vw_Venda 
AS
SELECT a.*,b.SalesOrderDetailID,b.ProductID, b.LineTotal
FROM Vendas.tb_Venda a
JOIN Vendas.tb_Venda_Detalhe b ON a.SalesOrderID = b.SalesOrderID
GO

CREATE OR ALTER PROC Vendas.spu_Venda 
@SalesOrderID int
AS
SELECT a.*
FROM Vendas.tb_Venda a
WHERE a.SalesOrderID = @SalesOrderID
GO

CREATE OR ALTER PROC Vendas.spu_Venda_Detalhe 
@SalesOrderID INT
AS
SELECT b.*
FROM Vendas.tb_Venda_Detalhe b
WHERE b.SalesOrderID = @SalesOrderID
GO

/****************** FIM Prepara Hands On ****************************/


-- Cria Usuário de Banco de Dados
CREATE USER Teste FOR LOGIN Teste

EXECUTE AS USER = 'Teste'
REVERT

SELECT * FROM dbo.Cliente
SELECT * FROM Vendas.tb_Venda
SELECT * FROM Vendas.tb_Venda_Detalhe
SELECT * FROM Vendas.vw_Venda

EXEC Vendas.spu_Venda @SalesOrderID = 53478
EXEC Vendas.spu_Venda_Detalhe @SalesOrderID = 53478

-- Permissão no nível do SCHEMA
GRANT EXECUTE ON SCHEMA::Vendas TO Teste
REVOKE EXECUTE ON SCHEMA::Vendas TO Teste

GRANT SELECT ON SCHEMA::Vendas TO Teste
DENY SELECT ON Vendas.vw_Venda TO Teste

-- Permissão no nível do Objeto
GRANT EXECUTE ON OBJECT::Vendas.spu_Venda TO Teste
REVOKE EXECUTE ON Vendas.spu_Venda FROM Teste

GRANT SELECT ON dbo.Cliente TO Teste

/*************************
 Views de Catálogo
**************************/
SELECT dp.name AS usuarioBD,
obj.name AS Objeto,
perms.state_desc AS [Status],
[permission_name] AS Permissao
FROM sys.database_permissions perms
JOIN sys.database_principals dp ON perms.grantee_principal_id = dp.principal_id
JOIN sys.objects obj ON perms.major_id = obj.object_id
ORDER BY usuarioBD

/*************************************
 Exclui Objetos do Hands On
*************************************/

USE master
GO

DROP DATABASE IF EXISTS HandsOn
GO

DROP LOGIN Teste
GO
