/***********************************
 Hands On: Auditoria com Trigger DML
************************************/

USE Aula
GO

/****************************
 Tabela Cliente
*****************************/
CREATE TABLE dbo.Cliente (
Cliente_ID INT NOT NULL IDENTITY CONSTRAINT pk_Cliente PRIMARY KEY,
Nome VARCHAR(100) NOT NULL,  
Telefone VARCHAR(40) NULL,
Email VARCHAR(200) NULL)
GO

/**********************
 Tabela de Auditoria
***********************/ 
DROP TABLE IF EXISTS dbo.Cliente_Hist
GO

CREATE TABLE dbo.Cliente_Hist (
Cliente_Hist_ID INT NOT NULL IDENTITY CONSTRAINT pk_Cliente_Hist PRIMARY KEY,
Operacao VARCHAR(20) NOT NULL,
Operacao_DataHora DATETIME NOT NULL,
Operacao_Login SYSNAME NULL,
Operacao_User SYSNAME NULL,
Operação_App SYSNAME NULL,
Operação_Host SYSNAME NULL,

Cliente_ID INT not null,
Nome VARCHAR(100) not null,  
Telefone VARCHAR(40) null,
Email VARCHAR(200) null,
Email_Anterior VARCHAR(200) null) 
GO

/*********************************************
 Uma Trigger para cada operação
**********************************************/
-- Auditoria DML INSERT
CREATE OR ALTER Trigger trg_audit_Cliente_INSERT ON dbo.Cliente 
FOR INSERT
AS
SET NOCOUNT ON

INSERT dbo.Cliente_Hist
(Operacao, Operacao_DataHora, Operacao_Login, Operacao_User, Operação_App, Operação_Host, Cliente_ID, Nome, Telefone, Email)
SELECT 'INSERT', getdate(), suser_sname(), user_name(), app_name(),host_name(), Cliente_ID, Nome, Telefone, Email
FROM Inserted
GO

-- Auditoria DML UPDATE
CREATE OR ALTER Trigger trg_audit_Cliente_UPDATE ON dbo.Cliente 
FOR UPDATE
AS
SET NOCOUNT ON

INSERT dbo.Cliente_Hist
(Operacao, Operacao_DataHora, Operacao_Login, Operacao_User, Operação_App, Operação_Host, Cliente_ID, Nome, Telefone, Email, Email_Anterior)
SELECT 'UPDATE', getdate(), suser_sname(), user_name(), app_name(),host_name(), i.Cliente_ID, i.Nome, i.Telefone, i.Email, d.Email
FROM Inserted i
JOIN Deleted d ON i.Cliente_ID = d.Cliente_ID
GO

-- Auditoria DML DELETE
CREATE OR ALTER Trigger trg_audit_Cliente_DELETE ON dbo.Cliente 
FOR DELETE
AS
SET NOCOUNT ON

INSERT dbo.Cliente_Hist
(Operacao, Operacao_DataHora, Operacao_Login, Operacao_User, Operação_App, Operação_Host, Cliente_ID, Nome, Telefone, Email)
SELECT 'DELETE', getdate(), suser_sname(), user_name(), app_name(),host_name(), Cliente_ID, Nome, Telefone, Email
FROM Deleted
GO

/***************************
 Testando Triggers
***************************/

INSERT dbo.Cliente (Nome, Telefone, Email)
VALUES ('José', '91111-1111','jose@google.com')

INSERT dbo.Cliente (Nome, Telefone, Email) VALUES
('Ana', '92222-2222','ana@google.com'),
('Landry', '93333-3333','landry@google.com'),
('Marina', '94444-4444','marina@google.com')

UPDATE dbo.Cliente SET Email = 'marinasoares@google.com'
WHERE Nome = 'Marina'

UPDATE dbo.Cliente SET Email = 'xxx@google.com'

DELETE dbo.Cliente WHERE Nome = 'Marina'

DELETE dbo.Cliente 

-- Consulta Tabela de Auditoria
SELECT * FROM dbo.Cliente_Hist

-- Exclui as 3 Triggers
DROP Trigger trg_audit_Cliente_INSERT
DROP Trigger trg_audit_Cliente_UPDATE
DROP Trigger trg_audit_Cliente_DELETE
GO

/*************************************************
 Uma Trigger para as 3 operações
**************************************************/
-- Tabela de Auditoria

DROP TABLE IF EXISTS dbo.Cliente_Hist
GO
CREATE TABLE dbo.Cliente_Hist (
Cliente_Hist_ID INT NOT NULL IDENTITY CONSTRAINT pk_Cliente_Hist PRIMARY KEY,
Operacao VARCHAR(20) NOT NULL,
Operacao_DataHora DATETIME NOT NULL,
Operacao_Login SYSNAME NULL,
Operacao_User SYSNAME NULL,
Operação_App SYSNAME NULL,
Operação_Host SYSNAME NULL,

Registro_Atual xml NULL,
Registro_Anterior xml NULL) 
GO

-- Trigger INSERT, UPDATE e DELETE

CREATE OR ALTER Trigger trg_audit_Cliente ON dbo.Cliente 
FOR INSERT,UPDATE,DELETE
AS
SET NOCOUNT ON

DECLARE @Operacao VARCHAR(20)
IF EXISTS (SELECT * FROM inserted)
	IF EXISTS (SELECT * FROM deleted)
		SELECT @Operacao = 'UPDATE'
	ELSE
		SELECT @Operacao = 'INSERT'
ELSE
	SELECT @Operacao = 'DELETE'

DECLARE @Registro_Atual xml, @Registro_Anterior xml 
SET @Registro_Atual = (SELECT * FROM inserted FOR XML PATH)
SET @Registro_Anterior = (SELECT * FROM deleted FOR XML PATH)

INSERT dbo.Cliente_Hist
(Operacao, Operacao_DataHora, Operacao_Login, Operacao_User, Operação_App, Operação_Host, Registro_Atual, Registro_Anterior)
SELECT @Operacao, getdate(), suser_sname(), user_name(), app_name(),host_name(), @Registro_Atual, @Registro_Anterior
GO

/******************** FIM Trigger ***************************/


/***************************
 Testando Trigger
***************************/
TRUNCATE TABLE dbo.Cliente

INSERT dbo.Cliente (Nome, Telefone, Email)
VALUES ('José', '91111-1111','jose@google.com')

INSERT dbo.Cliente (Nome, Telefone, Email) VALUES
('Ana', '92222-2222','ana@google.com'),
('Landry', '93333-3333','landry@google.com'),
('Marina', '94444-4444','marina@google.com')

UPDATE dbo.Cliente SET Email = 'marinasoares@google.com'
WHERE Nome = 'Marina'

UPDATE dbo.Cliente SET Email = 'xxx@google.com'

DELETE dbo.Cliente WHERE Nome = 'Marina'

DELETE dbo.Cliente 

-- Consulta Tabela de Auditoria
SELECT * FROM dbo.Cliente
SELECT * FROM dbo.Cliente_Hist
GO

-- Exclui Objetos
DROP TABLE IF EXISTS dbo.Cliente
DROP TABLE IF EXISTS dbo.Cliente_Hist
GO