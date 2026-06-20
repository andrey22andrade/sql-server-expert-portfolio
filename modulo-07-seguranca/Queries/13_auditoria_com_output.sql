/******************************
 Hands On: Auditoria com OUTPUT
*******************************/

USE Aula
GO

/**********************
 Tabela Funcionario
***********************/ 
DROP TABLE IF EXISTS dbo.Funcionario
GO

CREATE TABLE dbo.Funcionario (
Funcionario_ID INT NOT NULL IDENTITY CONSTRAINT pk_Funcionario PRIMARY KEY,
Nome VARCHAR(100) NOT NULL,
Cargo VARCHAR(50) NULL,
Data_Admissao DATE NULL,
Data_Demissao DATE NULL,
Salario DECIMAL (19,2) NULL) 
GO

INSERT dbo.Funcionario (Nome,Cargo,Data_Admissao,Salario) VALUES 
('Erick','Presidente','20120314',114000.00),
('Paula','Gerente Vendas','20190506',23000.00),
('Luana','Vendedor','20221202',5000.00),
('José','Diretor Vendas','20140518',55000.00)
GO

/**********************
 Tabela de Auditoria
***********************/ 
DROP TABLE IF EXISTS dbo.Funcionario_Hist
GO

CREATE TABLE dbo.Funcionario_Hist (
Funcionario_Hist_ID INT NOT NULL IDENTITY CONSTRAINT pk_Funcionario_Hist PRIMARY KEY,
Operacao VARCHAR(20) NOT NULL,
Operacao_DataHora DATETIME NOT NULL,
Operacao_Login SYSNAME NULL,
Operacao_User SYSNAME NULL,

Funcionario_ID INT,
Nome VARCHAR(100) NOT NULL,
Cargo VARCHAR(50) NULL,
Data_Admissao DATETIME NULL,
Data_Demissao DATETIME NULL,
Salario DECIMAL (19,2) NULL,
Salario_Anterior DECIMAL (19,2) NULL) 
GO

-- INSERT
INSERT dbo.Funcionario (Nome,Cargo,Data_Admissao,Salario) 
OUTPUT 'INSERT',getdate(),suser_sname(),user_name(),
inserted.Funcionario_ID,inserted.Nome,inserted.Cargo,inserted.Data_Admissao,
inserted.Data_Demissao,inserted.Salario,null
INTO Funcionario_Hist
VALUES ('Patricia','Vendedor','20240601',4000.00)

-- UPDATE
UPDATE Funcionario SET Salario = 5500.00
OUTPUT 'UPDATE',getdate(),suser_sname(),user_name(),
inserted.Funcionario_ID,inserted.Nome,inserted.Cargo,inserted.Data_Admissao,
inserted.Data_Demissao,inserted.Salario,deleted.Salario
INTO Funcionario_Hist
WHERE Funcionario_ID = 3

-- DELETE
DELETE Funcionario 
OUTPUT 'DELETE',getdate(),suser_sname(),user_name(),
deleted.Funcionario_ID,deleted.Nome,deleted.Cargo,deleted.Data_Admissao,
deleted.Data_Demissao,deleted.Salario,null
INTO Funcionario_Hist
WHERE Funcionario_ID = 2
GO

SELECT * FROM Funcionario
SELECT * FROM Funcionario_Hist
GO

-- Exclui tabelas
DROP TABLE IF EXISTS dbo.Funcionario
DROP TABLE IF EXISTS dbo.Funcionario_Hist
GO