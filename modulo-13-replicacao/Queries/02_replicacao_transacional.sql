/*********************************
 Hands ON: Replicação Transacional
**********************************/

USE master
GO

/********************** 
 Prepara Hands ON
***********************/
DROP DATABASE IF EXISTS VendasDB
GO
CREATE DATABASE VendasDB
GO

USE VendasDB
GO

DROP TABLE IF EXISTS dbo.Cliente 
GO
CREATE TABLE dbo.Cliente (
ClienteID INT NOT NULL CONSTRAINT pk_Cliente PRIMARY KEY,
Nome VARCHAR(50),
Telefone VARCHAR(20))
GO

INSERT dbo.Cliente VALUES 
(1,'Jose','1111-1111'),
(2,'Maria','2222-2222'),
(3,'Ana','3333-3333')
GO

DROP TABLE IF EXISTS dbo.Venda
GO
CREATE TABLE dbo.Venda (
VendaID INT NOT NULL IDENTITY CONSTRAINT pk_Venda PRIMARY KEY,
Data_Venda DATETIME NOT NULL,
ClienteID INT NULL,
ProdutoID INT NOT NULL,
Valor_Total DECIMAL(9,2) NULL)
GO

INSERT  dbo.Venda (Data_Venda,ClienteID,ProdutoID,Valor_Total) VALUES
(GETDATE()-5,1,1001,510.00),
(GETDATE()-5,2,2300,18510.00),
(GETDATE()-3,3,3100,2310.00),
(GETDATE()-3,1,2010,430.00),
(GETDATE()-1,2,1001,1020.00)
GO

CREATE VIEW vw_Venda AS
SELECT b.Nome,CAST(Data_Venda AS DATE) AS Dia,SUM(Valor_Total) AS Valor_Total
FROM dbo.Venda a
JOIN dbo.Cliente b ON b.ClienteID = a.ClienteID
GROUP BY b.Nome,CAST(Data_Venda AS DATE)
GO

CREATE PROC spu_Venda AS
SELECT b.Nome,CAST(Data_Venda AS DATE) AS Dia,SUM(Valor_Total) AS Valor_Total
FROM dbo.Venda a
JOIN dbo.Cliente b ON b.ClienteID = a.ClienteID
GROUP BY b.Nome,CAST(Data_Venda AS DATE)
GO
/****************** Fim Prepara Hands ON ***********************/

USE VendasDB
GO

SELECT * FROM VendasDB.dbo.Cliente
SELECT * FROM VendasDB.dbo.Venda
SELECT * FROM VendasDB.dbo.vw_Venda

-- Sincronia no menor tempo de latência
INSERT dbo.Cliente VALUES (4,'Paula','4444-4444')
INSERT  dbo.Venda (Data_Venda,ClienteID,ProdutoID,Valor_Total) VALUES (GETDATE()-1,4,5001,2200.00)

-- Não sincroniza! Tem que fazer outro Snapshot!
GO
CREATE or ALTER VIEW vw_Venda AS
SELECT b.Nome,CAST(Data_Venda AS DATE) AS Dia,SUM(Valor_Total) AS Valor_Total, COUNT(*) AS Qtd_Vendas--, avg(Valor_Total) AS Valor_Avg
FROM dbo.Venda a
JOIN dbo.Cliente b ON b.ClienteID = a.ClienteID
GROUP BY b.Nome,CAST(Data_Venda AS DATE)
GO


/*********************
 Exclui banco
**********************/

USE master
GO
DROP DATABASE IF EXISTS VendasDB
GO