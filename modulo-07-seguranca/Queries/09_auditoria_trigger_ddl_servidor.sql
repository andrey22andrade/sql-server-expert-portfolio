/********************************************
 Hands On: Triger DDL para auditoria Servidor
*********************************************/

/********************************
 Cria tabela de auditoria
*********************************/

USE DBA
GO

DROP TABLE IF EXISTS DBA.dbo.DBA_Audit_DDL_SRV
GO

CREATE TABLE DBA.dbo.DBA_Audit_DDL_SRV (
DDL_AuditID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
DataHora DATETIME NOT NULL,
NomeBanco VARCHAR(1000) NULL,
NomeLogin VARCHAR(256) NULL,
NomeDBUser VARCHAR(256) NULL,
NomeIPhost VARCHAR(256) NULL,
Operacao VARCHAR(500) NULL,
Comando VARCHAR(max) NULL,
Notificacao CHAR(1) NULL DEFAULT ('N'))
GO

SELECT name, object_id, is_disabled
FROM master.sys.server_triggers 
GO

/**************************************************************************
 Cria Trigger DDL no Servidor para alimentar a tabela de auditoria
***************************************************************************/
USE master
GO

CREATE OR ALTER TRIGGER DBA_AuditDDL ON ALL SERVER
WITH EXECUTE AS 'SRVSQL2022\landry'
FOR DDL_SERVER_LEVEL_EVENTS 
AS

SET NOCOUNT ON 

DECLARE @data XML
DECLARE @cmd VARCHAR(max)
DECLARE @posttime VARCHAR(24)
DECLARE @databasename VARCHAR(1000)
DECLARE @hostname VARCHAR(256)
DECLARE @loginname VARCHAR(256)
DECLARE @username VARCHAR(256)
DECLARE @operacao varchar(500)
SET @data = eventdata()

SET @operacao = CONVERT(VARCHAR(500),@data.query('data(//EventType)'))
SET @cmd = replace(CONVERT(VARCHAR(max),@data.query('data(//TSQLCommand//CommandText)')),'&#x0D;','')
SET @posttime = CONVERT(VARCHAR(24),@data.query('data(//PostTime)'))
SET @databasename = CONVERT(VARCHAR(1000),@data.query('data(//DatabaseName)'))
SET @hostname = left(HOST_NAME(),256)
SET @loginname = CONVERT(VARCHAR(256),@data.query('data(//LoginName)'))
SET @username = left(USER_NAME(),256)

IF @loginname <> 'SRVSQL2022\SQLService'
	INSERT dba.dbo.DBA_Audit_DDL_SRV
	(DataHora, NomeBanco, NomeLogin, NomeDBUser, NomeIPhost, Operacao, Comando) VALUES
	(@posttime, @databasename, @loginname, @username,@hostname,@operacao,@cmd)

--SELECT @data
GO

-- DISABLE TRIGGER DBA_AuditDDL ON ALL SERVER
-- ENABLE TRIGGER DBA_AuditDDL ON ALL SERVER


/******************** Hands On *******************************/
USE master
GO

-- Cria Login para Hands On
CREATE LOGIN [TesteAudit] WITH PASSWORD=N'123', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
EXEC master..sp_addsrvrolemember @loginame = N'TesteAudit', @rolename = N'dbcreator'
GO

EXECUTE AS LOGIN = 'TesteAudit'

-- Cria, altera e exclui banco
CREATE DATABASE TesteAudit
GO

ALTER DATABASE TesteAudit set recovery simple
GO

DROP DATABASE IF EXISTS TesteAudit 
GO

REVERT

-- Apaga Login
DROP LOGIN [TesteAudit]
GO

SELECT * FROM DBA.dbo.DBA_Audit_DDL_SRV
TRUNCATE TABLE DBA.dbo.DBA_Audit_DDL_SRV
GO

/*************************
 Exclui Trigger e Tabela
**************************/
USE master
GO

DROP TRIGGER DBA_AuditDDL ON ALL SERVER
GO

DROP TABLE IF EXISTS DBA.dbo.DBA_Audit_DDL_SRV
GO