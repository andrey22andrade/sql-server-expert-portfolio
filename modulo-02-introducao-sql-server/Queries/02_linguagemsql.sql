/**** Linguagem SQL ****/

USE master
GO

CREATE DATABASE Aula
GO

USE Aula
GO

/***************************
 Erro de sintaxe
****************************/

CREATE TABLE TesteErro (Col1 CHAR(10))

-- Exemplo 1
INSERT TesteErro VALUES ('Teste1')
INSERT TesteErro ('Teste2')
INSERT TesteErro VALUES ('Teste3')
GO

-- Tabela está vazia
SELECT * FROM TesteErro
GO

-- Exemplo 2
INSERT TesteErro VALUES ('Teste1')
INSERT TesteErro ('Teste2')
GO

INSERT TesteErro VALUES ('Teste3')
GO

-- Último INSERT executou
SELECT * FROM TesteErro
GO

-- Apaga todas as linhas da tabela
TRUNCATE TABLE TesteErro
GO

/***************************
 Erro de execução
****************************/
SELECT newid()
GO

-- Exemplo 1
INSERT TesteErro VALUES ('Teste1')
INSERT TesteErro VALUES (newid())
INSERT TesteErro VALUES ('Teste3')
GO

-- Último INSERT executou
SELECT * FROM TesteErro
GO

-- Exclui tabela
DROP TABLE IF EXISTS TesteErro

/***************************
 Nome de Objetos
****************************/

-- Nome errado
CREATE TABLE Nota Fiscal (Col1 VARCHAR(10))
GO

CREATE TABLE 1NotaFiscal (Col1 VARCHAR(10))
GO
-- Delimitador de nome de Objeto
CREATE TABLE [Nota Fiscal] (Col1 VARCHAR(10))
GO

CREATE TABLE [1NotaFiscal] (Col1 VARCHAR(10))
GO

/***********************************
 Nome do Objeto com 4 partes
************************************/
CREATE SCHEMA Vendas
GO

CREATE TABLE Cliente (Nome varchar(50), Idade int)

INSERT Cliente VALUES
('Landry', 55),
('Paula',45)
GO

CREATE TABLE Vendas.Cliente (Nome varchar(50), Idade int)

INSERT Vendas.Cliente VALUES ('Pedro', 32)
GO

SELECT * FROM Cliente
SELECT * FROM dbo.Cliente
SELECT * FROM Vendas.Cliente
GO

/**********************
 Exclui objetos
***********************/
DROP TABLE IF EXISTS dbo.Cliente
DROP TABLE IF EXISTS Vendas.Cliente
GO

DROP SCHEMA Vendas
GO

/**********************************
 Variável
 - Restaurar AdventureWorks antes
***********************************/
SELECT *
FROM AdventureWorks.Person.Person
WHERE FirstName = 'Ken'
GO

-- Exemplo 1
DECLARE @Codigo int,@Nome varchar(20)
SET @Nome = 'Ken'

SELECT @Codigo = BusinessEntityID
FROM AdventureWorks.Person.Person
WHERE FirstName = @Nome

SELECT @Codigo as Codigo 
GO
-- Exemplo 2
DECLARE @Codigo int,@Nome varchar(20)
SET @Nome = 'Ken'

SET @Codigo = (SELECT BusinessEntityID
               FROM AdventureWorks.Person.Person
               WHERE FirstName = @Nome)

SELECT @Codigo AS Codigo 
GO
-- Erro

/*************************************
 Instruções Dinâmicas
**************************************/

-- Exemplo 1
DECLARE @Banco VARCHAR(100), @Tabela VARCHAR(100)
SET @Banco = 'AdventureWorks'
SET @Tabela = 'Production.Product'

EXECUTE('USE ' + @Banco + ' SELECT * FROM ' + @Tabela)
GO

-- Exemplo 2
DECLARE @Banco VARCHAR(100), @Tabela VARCHAR(100)
SET @Banco = 'AdventureWorks'
SET @Tabela = 'Person.Person'

EXECUTE('USE ' + @Banco + ' SELECT * FROM ' + @Tabela)
GO

/******************************
 CASE
*******************************/
-- https://dataedo.com/samples/html/AdventureWorks/doc/AdventureWorks_2/tables/Production_Product_153.html

SELECT ProductID, Name AS Product, ProductLine,
CASE ProductLine
WHEN 'R' THEN 'Road'
WHEN 'M' THEN 'Mountain'
WHEN 'T' THEN 'Touring'
WHEN 'S' THEN 'Standard'
ELSE 'n/a'
END AS ProductLine_Desc
FROM AdventureWorks.Production.Product
GO