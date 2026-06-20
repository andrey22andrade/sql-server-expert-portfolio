/*******************************
 Hands On: Criptografia de dados
********************************/

USE master
GO

/***************************************************************
 Backup e Restore Service Master Key
 - Criada automaticamente quando cria a 1a Database Master Key
****************************************************************/
BACKUP SERVICE MASTER KEY TO FILE = 'C:\_LIVE\ServiceMaster.Key'
ENCRYPTION BY PASSWORD = 'Pa$$w0rd'

RESTORE SERVICE MASTER KEY FROM FILE = 'C:\_LIVE\ServiceMaster.Key'   
DECRYPTION BY PASSWORD = 'Pa$$w0rd'

/***********************
 Cria Banco
************************/

CREATE LOGIN Teste WITH PASSWORD = N'Pa$$w0rd', CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

DROP DATABASE IF EXISTS HandsOn
GO

CREATE DATABASE HandsOn
GO

-- Cria Tabela para demonstração

USE HandsOn
GO

DROP TABLE IF EXISTS dbo.Funcionario
GO

CREATE TABLE dbo.Funcionario (
FuncionarioID INT NOT NULL,
DataCadastro DATETIME DEFAULT GETDATE() NOT NULL,
CPF VARBINARY(MAX) NOT NULL)
GO

-- Cria usuário de banco de dados com acesso a tabela
CREATE USER Teste FOR LOGIN Teste
GRANT SELECT, INSERT, UPDATE ON dbo.Funcionario TO Teste
GO

-- Cria Database Master key
-- DROP MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pa$$w0rd'
GO

SELECT [name] NomeDaChave, symmetric_key_id, key_length, algorithm_desc
FROM sys.symmetric_keys
GO

-- Cria Certificado
-- DROP CERTIFICATE Cert_Dados
CREATE CERTIFICATE Cert_Dados WITH SUBJECT = 'Certificado para criptografia dos dados', EXPIRY_DATE = '99991231'
GO

SELECT [name] NomeDoCertificado, certificate_id, pvt_key_encryption_type_desc, 
issuer_name, [start_date], [expiry_date]
FROM sys.certificates
GO

-- Cria Chave Simétrica, criptografada no banco utilizando o Certificado
-- DROP SYMMETRIC KEY Key_Dados
CREATE SYMMETRIC KEY Key_Dados WITH ALGORITHM = AES_256 
ENCRYPTION BY CERTIFICATE Cert_Dados
GO

SELECT [name] NomeDaChave, symmetric_key_id, key_length, algorithm_desc
FROM sys.symmetric_keys
GO

/************************************
 Incluindo dados criptografados
*************************************/
OPEN SYMMETRIC KEY Key_Dados DECRYPTION BY CERTIFICATE Cert_Dados
GO

INSERT dbo.Funcionario (FuncionarioID, CPF)
VALUES (1, EncryptByKey(Key_GUID('Key_Dados'),'26899712234'))
GO

CLOSE ALL SYMMETRIC KEYS
GO

/************************************
 Consultando dados criptografados
*************************************/
SELECT * FROM dbo.Funcionario
GO

OPEN SYMMETRIC KEY Key_Dados DECRYPTION BY CERTIFICATE Cert_Dados
GO

SELECT FuncionarioID,DataCadastro,
CONVERT(varchar,DecryptByKey(CPF)) AS CPF 
FROM dbo.Funcionario
GO

CLOSE ALL SYMMETRIC KEYS
GO

/******************************************
 Tentando acessar com outro usuário
*******************************************/
EXECUTE AS USER = 'Teste'
REVERT
GO

OPEN SYMMETRIC KEY Key_Dados DECRYPTION BY CERTIFICATE Cert_Dados
GO

/*
Msg 15151, Level 16, State 1, Line 83
Cannot find the symmetric key 'Key_Dados', because it does not exist or you do not have permission.
*/

GRANT CONTROL ON CERTIFICATE::Cert_Dados TO Teste
GRANT VIEW DEFINITION ON SYMMETRIC KEY::Key_Dados to Teste
GO

SELECT FuncionarioID,DataCadastro,
CONVERT(varchar,DecryptByKey(CPF)) AS CPF 
FROM dbo.Funcionario
GO

CLOSE ALL SYMMETRIC KEYS
GO

/*************************************
 Excluindo Objetos do Hands On
**************************************/

DROP TABLE dbo.Funcionario
DROP SYMMETRIC KEY Key_Dados
DROP CERTIFICATE Cert_Dados
DROP MASTER KEY
DROP USER Teste
GO

USE master
GO

DROP LOGIN Teste
GO

DROP DATABASE IF EXISTS HandsOn
GO