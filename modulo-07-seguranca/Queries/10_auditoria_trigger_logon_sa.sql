/***************************************************
 Hands On: Trigger Logon para Auditoria Login com SA
****************************************************/

USE master
GO

DROP TABLE IF EXISTS msdb.dbo.DBA_AutitLogin
GO

CREATE TABLE msdb.dbo.DBA_AutitLogin (
Data DATETIME NULL,
SPIDid INT NULL,
LoginName SYSNAME NULL,
HostName SYSNAME NULL,
ProgramName SYSNAME NULL,
AuthScheme SYSNAME NULL,
NetTransport SYSNAME NULL,
ClienteAddress SYSNAME NULL,
LocalAddress SYSNAME NULL)
GO

--select SUSER_NAME(),app_name()
GO

/*******************************
 Cria trigger de Login
********************************/
CREATE OR ALTER TRIGGER trg_AuditLogin ON ALL SERVER FOR logon
AS

IF (ORIGINAL_LOGIN() = 'sa') and @@spid > 50 BEGIN

      INSERT msdb.dbo.DBA_AutitLogin
	  ([Data], SPIDid, LoginName, HostName, ProgramName, AuthScheme, NetTransport, ClienteAddress, LocalAddress)

      SELECT getdate(),@@spid,s.login_name,s.[host_name],
      s.program_name,c.auth_scheme,c.net_transport,
      c.client_net_address,c.local_net_address
      FROM sys.dm_exec_sessions s 
	  join sys.dm_exec_connections c ON s.session_id = c.session_id
      WHERE s.session_id = @@spid
       
END 
GO

/********************** FIM Trigger de Login ************************/

SELECT * FROM msdb.dbo.DBA_AutitLogin

/*****************************
 Exclui Trigger e tabela
******************************/
DROP TRIGGER trg_AuditLogin ON ALL SERVER
DROP TABLE IF EXISTS msdb.dbo.DBA_AutitLogin
GO