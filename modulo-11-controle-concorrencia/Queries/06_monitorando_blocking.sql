/***************************
 Hands On: Monitora Blocking
****************************/

USE master
GO

/*****************************************************************
 Função formata ID JOB para identificar JOB envolvido no Blocking
*****************************************************************/

CREATE OR ALTER FUNCTION dbo.udf_sysjobs_getprocessid(@job_id UNIQUEIDENTIFIER)
RETURNS VARCHAR(8)
AS
BEGIN
RETURN (SUBSTRING(left(@job_id,8),7,2) +
SUBSTRING(left(@job_id,8),5,2) +
SUBSTRING(left(@job_id,8),3,2) +
SUBSTRING(left(@job_id,8),1,2))
END
GO

/*************************** FIM Função *******************************/

/**********************************************************
 sys.dm_exec_sessions
 - Uma linha por conexão, incluindo conexões de sistema.

 https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-sessions-transact-sql?view=sql-server-ver16
***********************************************************/
SELECT * FROM sys.dm_exec_sessions
WHERE [SESSION_ID] > 50
ORDER BY [SESSION_ID]

/********************************************************************
 sys.dm_exec_connections
 - Uma linha por conexão de usuário, excluindo conexão de sistema.

 https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-connections-transact-sql?view=sql-server-ver16
*********************************************************************/
SELECT * FROM sys.dm_exec_connections
ORDER BY [SESSION_ID]

/**********************************************
 sys.dm_exec_requests
 - Uma linha por consulta em execução.

 https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-exec-requests-transact-sql?view=sql-server-ver16
***********************************************/
SELECT * FROM sys.dm_exec_requests
WHERE [SESSION_ID] > 50


-- Conexões por aplicação
SELECT s.SESSION_ID, s.login_name, s.PROGRAM_NAME, s.client_interface_name
FROM sys.dm_exec_sessions s
JOIN sys.dm_exec_connections c ON c.SESSION_ID = s.SESSION_ID

SELECT s.PROGRAM_NAME AS Aplicacao, count(*) AS QtdConexoes
FROM sys.dm_exec_sessions s
JOIN sys.dm_exec_connections c ON c.SESSION_ID = s.SESSION_ID
GROUP BY s.PROGRAM_NAME

-- Consiguração de sessão
SELECT s.SESSION_ID,s.login_name, DB_NAME(s.database_id) AS Banco,
s.date_format, s.quoted_identifier, s.ansi_nulls
FROM sys.dm_exec_sessions s
JOIN sys.dm_exec_connections c ON c.SESSION_ID = s.SESSION_ID
ORDER BY s.SESSION_ID

-- Em execução
SELECT *
FROM sys.dm_exec_sessions AS s
JOIN sys.dm_exec_connections AS c ON s.SESSION_ID = c.SESSION_ID
JOIN sys.dm_exec_requests AS r ON s.SESSION_ID = r.SESSION_ID
ORDER BY s.SESSION_ID

/**********************************************
 sys.sysprocesses
 - Uma linha por consulta em execução.
 - Visão de compatibilidade a versões anteriores

 https://learn.microsoft.com/pt-br/sql/relational-databases/system-compatibility-views/sys-sysprocesses-transact-sql?view=sql-server-ver16
***********************************************/
SELECT * FROM sys.sysprocesses

/******************************************
 Provoca Blocking
*******************************************/
DROP TABLE IF EXISTS Aula.dbo.Funcionario
GO
CREATE TABLE Aula.dbo.Funcionario (PK INT, Nome VARCHAR(50), Descricao VARCHAR(100), Status CHAR(1),Salario decimal(10,2))
INSERT Aula.dbo.Funcionario VALUES (9,'Erick','Operacional','C',2600.00)
INSERT Aula.dbo.Funcionario VALUES (10,'Joana','Operacional','C',2600.00)
GO

BEGIN TRAN
  UPDATE Aula.dbo.Funcionario SET Salario = 3000.00 WHERE PK = 10
  SELECT * FROM Aula.dbo.Funcionario WHERE PK = 10 -- Salario = 2600.00

ROLLBACK

/*******************************************************
 Retorna Blocking identificando o(s) processo(s) raiz
********************************************************/
-- Processo(s) Raiz
SELECT GETDATE() AS DataHora, spid AS SPID, 'RAIZ' AS Status, waittime/1000 AS TempoEspera_Seg, blocked AS SPID_Blocking,
DB_NAME(sp.dbid) Banco,CAST(RTRIM(ISNULL(hostname,'N/A')) AS VARCHAR(50)) Computador,
CASE WHEN sp.nt_domain is null OR sp.nt_domain = '' THEN 'N/A' ELSE RTRIM(sp.nt_domain) + '/' + nt_username END AS UsuarioWindows, 
CAST(RTRIM(loginame) AS VARCHAR(50)) AS LoginSQL, 
CASE 
WHEN s.PROGRAM_NAME like 'SQLAgent - TSQL JobStep (Job%' 
THEN (SELECT 'JOB: ' + MAX(name) + ' (' + REPLACE( SUBSTRING(s.PROGRAM_NAME,CHARINDEX(': Step',s.PROGRAM_NAME)+2,100) ,')','') + ')' 
FROM msdb.dbo.sysjobs WHERE dbo.udf_sysjobs_getprocessid(job_id) = SUBSTRING(s.PROGRAM_NAME,32,8) )
ELSE s.PROGRAM_NAME
END AS Aplicacao, 
s.client_interface_name AS AppInterface,
open_tran AS QtdTransacoes, cmd AS TipoComando, last_batch AS UltimoTSQL,qt.text AS InstrucaoTSQL

FROM sys.sysprocesses sp 
LEFT JOIN sys.dm_exec_sessions s ON s.SESSION_ID = sp.spid
OUTER APPLY sys.dm_exec_sql_text(sp.sql_handle) AS qt
WHERE spid in (SELECT distinct blocked FROM sys.sysprocesses where blocked > 0) AND blocked = 0

UNION 

-- Processo(s) que estão em Blocking
SELECT GETDATE(), spid AS SPID, 'BLOCK' AS Status, waittime/1000 AS TempoEspera_Seg, blocked AS SPID_Blocking,
DB_NAME(sp.dbid) Banco,CAST(RTRIM(ISNULL(hostname,'N/A')) AS VARCHAR(50)) Computador,
CASE WHEN sp.nt_domain is null OR sp.nt_domain = '' THEN 'N/A' ELSE RTRIM(sp.nt_domain) + '/' + nt_username END AS UsuarioWindows, 
CAST(RTRIM(loginame) AS VARCHAR(50)) AS LoginSQL, 
CASE 
WHEN s.PROGRAM_NAME like 'SQLAgent - TSQL JobStep (Job%' 
THEN (SELECT 'JOB: ' + MAX(name) + ' (' + REPLACE( SUBSTRING(s.PROGRAM_NAME,CHARINDEX(': Step',s.PROGRAM_NAME)+2,100) ,')','') + ')' FROM msdb.dbo.sysjobs WHERE dbo.udf_sysjobs_getprocessid(job_id) = SUBSTRING(s.PROGRAM_NAME,32,8) )
ELSE s.PROGRAM_NAME
END AS Aplicacao, 
s.client_interface_name AS AppInterface,
open_tran AS QtdTransacoes, cmd AS TipoComando, last_batch AS UltimoTSQL,qt.text AS InstrucaoTSQL

FROM sys.sysprocesses sp 
LEFT JOIN sys.dm_exec_sessions s ON s.SESSION_ID = sp.spid
OUTER APPLY sys.dm_exec_sql_text(sp.sql_handle) AS qt
WHERE  spid > 50 and blocked > 0
GO