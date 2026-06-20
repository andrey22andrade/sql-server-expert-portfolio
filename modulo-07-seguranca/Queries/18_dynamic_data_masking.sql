/******************************
 Hands On: Dynamic Data Masking
*******************************/

USE Aula
GO

DROP TABLE IF EXISTS Funcionario
GO

CREATE TABLE Funcionario(
Funcionario_ID INT NOT NULL CONSTRAINT pk_Funcionario PRIMARY KEY,
Nome VARCHAR(50) NOT NULL,
Sobrenome VARCHAR(50) MASKED WITH (FUNCTION = 'default()') NOT NULL,
Data_Aniversario DATE MASKED WITH (FUNCTION = 'default()') NOT NULL,
VendasUltimoAno MONEY MASKED WITH (FUNCTION = 'default()') NOT NULL,
Email VARCHAR(50),
Telefone VARCHAR(25))
GO

INSERT INTO Funcionario 
SELECT e.BusinessEntityID AS Funcionario_ID,
sp.FirstName AS Nome, sp.LastName AS Sobrenome,
e.BirthDate AS Data_Aniversario, sp.SalesLastYear AS VendasUltimoAno,
sp.EmailAddress AS Email, sp.PhoneNumber AS Telefone
FROM AdventureWorks.HumanResources.Employee e
JOIN AdventureWorks.Sales.vSalesPerson sp ON e.BusinessEntityID = sp.BusinessEntityID
WHERE sp.CountryRegionName = 'United States'
GO

-- Criando Usuário de Banco de Dados e atribuindo permissãona tabela
CREATE USER UsuarioTeste WITHOUT LOGIN
GRANT SELECT ON dbo.Funcionario TO UsuarioTeste 
GO

-- Visualizando os dados
SELECT * FROM FUNCIONARIO 
GO

-- Simulando acesso com UsuarioTeste
EXECUTE AS USER = 'UsuarioTeste'
REVERT
GO

-- Habilitar visualização dos dados MASKED
GRANT UNMASK TO UsuarioTeste
REVOKE UNMASK TO UsuarioTeste
GO

-- Adicionando mascara randomica
ALTER TABLE Funcionario ALTER COLUMN VendasUltimoAno money MASKED WITH (FUNCTION = 'random(101, 999)') NOT NULL
GO

-- Adicionando mascara parcial, começando na 1a posição e mostrando apenas as 5 últimas posições
ALTER TABLE Funcionario ALTER COLUMN Telefone varchar(25) MASKED WITH (FUNCTION = 'partial(0, "xxxxxxx", 5)') NOT NULL
GO

-- Adicionando mascara no email
ALTER TABLE Funcionario ALTER COLUMN Email varchar(50) MASKED WITH (FUNCTION = 'email()') NULL
GO

EXECUTE AS USER = 'UsuarioTeste'
GO

SELECT * FROM Funcionario 

REVERT
GO

/*
238-555-0197
257-555-0154
883-555-0116
*/

-- Lista colunas com Mask habilitado
SELECT OBJECT_NAME(object_id) AS Tabela, [name] AS Coluna, masking_function MaskFunction
FROM sys.masked_columns
ORDER BY Tabela, Coluna
GO

/*****************************
 Exclui objetos do Hands On
******************************/
DROP USER UsuarioTeste
DROP TABLE IF EXISTS Funcionario
GO