/**************************
 Hands ON: Replicação Merge
***************************/

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

ALTER TABLE dbo.Venda ADD CONSTRAINT fk_Venda_Cliente
FOREIGN KEY (ClienteID) REFERENCES dbo.Cliente(ClienteID)
GO

INSERT  dbo.Venda (Data_Venda,ClienteID,ProdutoID,Valor_Total) VALUES
(GETDATE()-5,1,1001,510.00),
(GETDATE()-5,2,2300,18510.00),
(GETDATE()-3,3,3100,2310.00),
(GETDATE()-3,1,2010,430.00),
(GETDATE()-1,2,1001,1020.00)
GO

CREATE VIEW vw_Venda AS
SELECT b.Nome,cast(Data_Venda AS date) AS Dia,SUM(Valor_Total) AS Valor_Total
FROM dbo.Venda a
JOIN dbo.Cliente b ON b.ClienteID = a.ClienteID
GROUP BY b.Nome,cast(Data_Venda AS date)
GO

CREATE PROC spu_Venda AS
SELECT b.Nome,cast(Data_Venda AS date) AS Dia,SUM(Valor_Total) AS Valor_Total
FROM dbo.Venda a
JOIN dbo.Cliente b ON b.ClienteID = a.ClienteID
GROUP BY b.Nome,cast(Data_Venda AS date)
GO

/****************** Fim Prepara Hands ON ***********************/

/******************************
 Sincronia Inicial
 \\SRVSQL2019\Backup
*******************************/

BACKUP DATABASE VendasDB TO DISK = 'C:\Backup\VendasDB.bak' WITH format,compression

RESTORE DATABASE VendasDB FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\VendasDB.bak' WITH recovery, replace,
MOVE 'VendasDB' TO 'C:\MSSQL_Data\VendasDB.mdf',
MOVE 'VendasDB_log' TO 'C:\MSSQL_Data\VendasDB_log.ldf'


/****************************
 Teste da Sincronia
*****************************/

USE VendasDB
GO
SELECT * FROM VendasDB.dbo.Cliente
SELECT * FROM VendasDB.dbo.Venda


-- Publisher
INSERT dbo.Cliente VALUES (4,'Paula','4444-4444')
INSERT  dbo.Venda (Data_Venda,ClienteID,ProdutoID,Valor_Total) VALUES (GETDATE()-1,4,5001,2200.00)

-- Subscriber
UPDATE dbo.Cliente SET Telefone = 'AAAA-AAAA' WHERE ClienteID = 1 -- Publisher


ALTER AUTHORIZATION ON DATABASE::VendasDB TO sa

/*********************
 Exclui banco
**********************/
USE master
GO
DROP DATABASE IF EXISTS VendasDB
GO