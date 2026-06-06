/***************************************
 Hands On:
 - Criando tabela
 - PK (Primary Key - Chave Primária)
 - UNIQUE
 - FK (Foreign Key - Chave Estrangeira)
***************************************/

USE Aula
GO

/**********************************************************************
 Criando nova tabela no schema padrão "dbo"

 Regras para definir nomes de objetos:
  - Máximo 128 caracteres
  - Primeira posição do nome tem que ser uma letra
  - Demais posições letras, números e símbolos (@, _, $, #)
  - [ ... ] delimita nome de objeto, exemplo [nota fiscal]
  - ' ... ' delimita string
  - Nome completo: instância.banco.schema.<nome do objeto>
**********************************************************************/

-- Não pode ter espaço
CREATE TABLE Nota Fiscal (col1 INT)
CREATE TABLE [Nota Fiscal] (col1 INT)
GO

-- Tem que começar com letra
CREATE TABLE 1Cliente (col1 INT)
CREATE TABLE [1Cliente] (col1 INT)
GO

-- A partir do SQL Server 2016!
DROP TABLE IF EXISTS Cliente
GO

CREATE TABLE Cliente (
Cliente_ID INT NOT NULL,
Nome VARCHAR(40) NOT NULL,
Data_Cadastro DATETIME NOT NULL,
Renda_Anual DECIMAL(12,2) NULL)
GO

INSERT Cliente VALUES (1,'Landry','20200528 12:30:00.000',20000.00)
GO

SELECT * FROM Cliente
SELECT * FROM SRVSQL2022.Aula.dbo.Cliente
GO

/*******************************
 Criando novo SCHEMA "Vendas"
********************************/

CREATE SCHEMA Vendas
GO

/***********************************************
 Criando tabela "Cliente" noo SCHEMA "Vendas"
************************************************/
-- DROP TABLE Vendas.Cliente
CREATE TABLE Vendas.Cliente (
Cliente_ID INT NOT NULL,
Nome VARCHAR(40) NOT NULL,
Data_Cadastro DATETIME NOT NULL,
Renda_Anual DECIMAL(12,2) NULL)

SELECT * FROM Cliente
SELECT * FROM dbo.Cliente
SELECT * FROM Vendas.Cliente
GO

/**********************************************
 CONSTRAINT PK (Primary Key - Chave Primária)
***********************************************/
SELECT * FROM dbo.Cliente
GO

INSERT Cliente VALUES (1,'Landry','20200528 12:30:00.000',25000.00)
GO

/*********************************************
 Alterando tabela "Cliente" adicionando PK
**********************************************/
TRUNCATE TABLE dbo.Cliente
GO

ALTER TABLE dbo.Cliente ADD CONSTRAINT pk_Cliente PRIMARY KEY (Cliente_ID)
GO

INSERT Cliente VALUES (1,'Landry','20200528 12:30:00.000',20000.00)
INSERT Cliente VALUES (1,'Landry','20200528 12:30:00.000',25000.00)
GO

/* Erro
Msg 2627, Level 14, State 1, Line 66
Violation of PRIMARY KEY constraint 'pk_Cliente'. Cannot insert duplicate key in object 'dbo.Cliente'. The duplicate key value is (1).
*/

SELECT * FROM dbo.Cliente
GO

INSERT Cliente VALUES (2,'Landry','20200528 12:30:00.000',25000.00)
GO

DELETE dbo.Cliente WHERE Cliente_ID = 2
GO

-- Cria Constraint UNIQUE
ALTER TABLE dbo.Cliente ADD CONSTRAINT unq_Cliente UNIQUE (Nome)
GO

INSERT Cliente VALUES (2,'Landry','20200528 12:30:00.000',25000.00)
GO

INSERT Cliente VALUES (2,'Luana','20201018 09:20:00.000',25000.00)
GO

/********************************************
 Criando tabela "Cliente" com PK e UNIQUE
*********************************************/
-- DROP TABLE dbo.Cliente

CREATE TABLE dbo.Cliente (
Cliente_ID INT NOT NULL,
Nome VARCHAR(40) NOT NULL,
Data_Cadastro DATETIME NOT NULL,
Renda_Anual DECIMAL(12,2) NULL,
CONSTRAINT pk_Cliente PRIMARY KEY (Cliente_ID),
CONSTRAINT unq_Cliente_Nome UNIQUE (Nome))
GO

/*****************************************************************
 Criando tabela "Pedido" com FK (Foreign Key - Chave Estrangeira)
******************************************************************/
-- DROP TABLE dbo.Pedido
CREATE TABLE dbo.Pedido (
Pedido_ID INT NOT NULL,
Cliente_ID INT NOT NULL,
Data_Pedido DATETIME NOT NULL,
Valor_Total DECIMAL(12,2) NULL,
CONSTRAINT pk_Pedido PRIMARY KEY (Pedido_ID))
GO

ALTER TABLE dbo.Pedido ADD CONSTRAINT fk_Pedido_Cliente
FOREIGN KEY (Cliente_ID) REFERENCES dbo.Cliente (Cliente_ID)
GO

SELECT * FROM dbo.Cliente
GO

INSERT dbo.Pedido (Pedido_ID,Cliente_ID,Data_Pedido,Valor_Total)
VALUES (1,3,'20210205 10:50:00.000',3000.00)
GO

/* Erro
Msg 547, Level 16, State 0, Line 115
The INSERT statement conflicted with the FOREIGN KEY constraint "fk_Pedido_Cliente". The conflict occurred in database "Aula", table "dbo.Cliente", column 'Cliente_ID'.
*/

INSERT dbo.Pedido (Pedido_ID,Cliente_ID,Data_Pedido,Valor_Total) 
VALUES (1,2,'20210205 11:00:00.000',3000.00)
GO

SELECT * FROM dbo.Pedido
GO

/*
DROP TABLE dbo.Pedido
DROP TABLE dbo.Cliente
DROP TABLE Vendas.Cliente
DROP SCHEMA Vendas
*/