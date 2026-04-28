/*********************************
Transparent data encryption (TDE)
**********************************/

USE master
GO

/****************** Prepara Hands On ***********************/
DROP DATABASE IF EXISTS DBCript
GO

CREATE DATABASE DBCript
GO

USE DBCript
GO

-- DROP TABLE dbo.Clientes 
CREATE TABLE dbo.Clientes (
ClienteID INT NOT NULL CONSTRAINT pk_Clientes PRIMARY KEY,
Nome VARCHAR(50),
Telefone VARCHAR(20))
GO

INSERT dbo.Clientes VALUES 
(1,'Jose','1111-1111'),
(2,'Maria','2222-2222'),
(3,'Maria','3333-3333')
GO

SELECT * FROM dbo.Clientes
GO

/********************************/

USE master
GO

-- Cria Master Key
-- DROP MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pa$$w0rd';

-- Cria Certificado
-- DROP CERTIFICATE DBCriptCert
CREATE CERTIFICATE DBCriptCert WITH SUBJECT = 'Certificado para TDE', EXPIRY_DATE = '99991231'

-- Backup Certificado
BACKUP CERTIFICATE DBCriptCert TO FILE = 'C:\_HandsOn_AdmSQL\Backup\DBCriptCert.cer'
WITH PRIVATE KEY (FILE = 'C:\_HandsOn_AdmSQL\Backup\DBCriptCert.key',
ENCRYPTION BY PASSWORD = 'Pa$$w0rd')


/*********************************
 Habilitando TDE
**********************************/
USE DBCript
GO

CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE DBCriptCert

ALTER DATABASE DBCript SET ENCRYPTION ON

/**************************
 Backup com criptografia
***************************/
BACKUP DATABASE DBCript TO DISK = 'C:\_HandsOn_AdmSQL\Backup\DBCript.bak' WITH INIT,COMPRESSION
GO

-- Ver status de Banco criptografado
SELECT name AS Banco, is_encrypted 
FROM sys.databases 
WHERE name = 'DBCript'

/*************************
 Verifica Status
**************************/
SELECT DB_NAME(database_id) AS Banco,
encryption_state, encryption_state_desc, percent_complete,
key_algorithm, key_length, encryptor_type
FROM sys.dm_database_encryption_keys
WHERE DB_NAME(database_id) IN ('DBCript')
AND percent_complete > 0
ORDER BY Banco

SELECT name AS Banco, is_encrypted 
FROM sys.databases
WHERE database_id > 4
AND name NOT IN ('ReportServer','ReportServerTempDB','SSISDB')
ORDER BY name

/**************************************
 - Restore na instancia2 gera erro
***************************************/
RESTORE DATABASE DBCript FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\DBCript.bak' WITH
MOVE 'DBCript' TO 'C:\MSSQL_Data_SQL02\DBCript.mdf',
MOVE 'DBCript_Log' TO 'C:\MSSQL_Data_SQL02\DBCript_Log.ldf'
/*
Msg 33111, Level 16, State 3, Line 66
Cannot find server certificate with thumbprint '0xE9323F15BA9A9BBD57EED44EC88B41A1C010D6A7'.
Msg 3013, Level 16, State 1, Line 66
RESTORE DATABASE is terminating abnormally.
*/

-- Cria Master Key
USE master
GO

-- DROP MASTER KEY
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Pa$$w0rd'
GO

-- Importa Certificado
-- DROP CERTIFICATE DBCriptCert
CREATE CERTIFICATE DBCriptCert FROM FILE = 'C:\_HandsOn_AdmSQL\Backup\DBCriptCert.cer'
WITH PRIVATE KEY ( FILE = 'C:\_HandsOn_AdmSQL\Backup\DBCriptCert.key', 
DECRYPTION BY PASSWORD = 'Pa$$w0rd')
GO

-- Restaurar o banco

-- DROP
USE master
GO

DROP DATABASE IF EXISTS DBCript
DROP CERTIFICATE DBCriptCert
DROP MASTER KEY
GO