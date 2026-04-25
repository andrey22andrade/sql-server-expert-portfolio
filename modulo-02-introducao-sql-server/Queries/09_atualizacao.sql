/**** INSERT, UPDATE e DELETE ****/

USE Aula
GO

/***************************************
 Hands On: INSERT
****************************************/

-- Cria tabelas para Hands On
DROP TABLE IF EXISTS dbo.Clientes 
GO

CREATE TABLE Clientes (
ClienteID INT NOT NULL IDENTITY PRIMARY KEY,
Nome VARCHAR(50) NOT NULL,
Bairro VARCHAR(40) NULL,
Sexo CHAR(1) NOT NULL DEFAULT 'M',
Credito CHAR(1) NOT NULL DEFAULT 'A')
GO


INSERT Clientes (Nome,Bairro,Sexo,Credito)
VALUES ('Jose','Copacabana','M','A')
GO

SELECT * FROM Clientes
GO

-- DEFAULT
INSERT Clientes (Nome,Bairro)
VALUES ('Maria','Barra da Tijuca')
GO

INSERT Clientes (Nome,Bairro,Sexo)
VALUES ('Paula','Ipanema',DEFAULT)
GO

-- Tabela Temporária LOCAL
SELECT * 
INTO #tmp_Clientes
FROM Clientes
GO

SELECT * FROM #tmp_Clientes
GO

DROP TABLE #tmp_Clientes
GO

-- Tabela Temporária GLOBAL
SELECT * 
INTO ##tmp_Clientes
FROM Clientes
GO

SELECT * FROM ##tmp_Clientes
GO

DROP TABLE ##tmp_Clientes
GO

/***************************
 Hands On: UPDATE
****************************/
UPDATE Clientes SET Sexo = 'F'
WHERE Nome = 'Maria'
GO

UPDATE Clientes SET Bairro = 'Leblon'
GO

-- UPDATE com JOIN
DROP TABLE IF EXISTS dbo.Vendas 
GO

CREATE TABLE Vendas (
VendaID INT NOT NULL IDENTITY PRIMARY KEY,
ClienteID INT NOT NULL,
Vendedor VARCHAR(50) NOT NULL,
TotalVenda DECIMAL(10,2) NULL)
GO

TRUNCATE TABLE Clientes
GO

INSERT Clientes (Nome,Bairro,Sexo) VALUES ('Jose','Copacabana','M')
INSERT Clientes (Nome,Bairro,Sexo) VALUES ('Maria','Barra da Tijuca','F')
INSERT Clientes (Nome,Bairro,Sexo) VALUES ('Paula','Ipanema','F')
GO

INSERT Vendas (ClienteID,Vendedor,TotalVenda) VALUES (1,'Paulo',5000.00)
INSERT Vendas (ClienteID,Vendedor,TotalVenda) VALUES (1,'Antonio',10000.00)
INSERT Vendas (ClienteID,Vendedor,TotalVenda) VALUES (2,'Paulo',2000.00)
INSERT Vendas (ClienteID,Vendedor,TotalVenda) VALUES (2,'Antonio',30000.00)
GO

SELECT * FROM Clientes
SELECT * FROM Vendas
GO

-- Alterar o Credito para "B" dos clientes que nao compraram
UPDATE c SET Credito = 'B'
FROM Clientes c LEFT JOIN Vendas v
ON c.ClienteID = v.ClienteID
WHERE v.VendaID IS NULL
GO

/*************************
 Demonstracao DELETE
**************************/

DELETE Vendas WHERE Vendedor = 'Paulo'
GO

SELECT * FROM Clientes
SELECT * FROM Vendas
GO

-- Excluir Clientes que nao compraram
DELETE c
FROM Clientes c LEFT JOIN Vendas v
ON c.ClienteID = v.ClienteID
WHERE v.VendaID IS NULL
GO

/**********************
  Exclui tabelas
************************/
DROP TABLE IF EXISTS dbo.Clientes 
DROP TABLE IF EXISTS dbo.Vendas 
GO