/*******************************
 Hands ON: JOB Monitora Blocking
********************************/

/******************************************************
 Cria Tabela para incluir informações de Blocking
*******************************************************/

USE DBA
GO

-- TRUNCATE TABLE DBA.dbo.DBA_Monitora_Hist_Blocking
DROP TABLE IF EXISTS DBA.dbo.DBA_Monitora_Hist_Blocking
GO
CREATE TABLE dbo.DBA_Monitora_Hist_Blocking (
DataHora_Coleta DATETIME NOT NULL,
SPID SMALLINT NOT NULL,
Status VARCHAR(5) NOT NULL,
TempoEspera_Seg BIGINT NULL,
SPID_Blocking SMALLINT NULL,
Banco NVARCHAR(128) NULL,
Computador NCHAR(128) NULL,
UsuarioWindows NVARCHAR(257) NULL,
LoginSQL NCHAR(128) NULL,
Aplicacao NVARCHAR(128) NULL,
AppInterface NVARCHAR(32) NULL,
QtdTransacoes SMALLINT NULL,
TipoComando NCHAR(16) NULL,
UltimoTSQL DATETIME NULL,
InstrucaoTSQL VARCHAR(MAX) NULL,
Email CHAR(1) NOT NULL,
encrypted BIT NULL)
GO

SELECT * FROM dbo.DBA_Monitora_Hist_Blocking
GO

/***********************************************************************
 Função formata ID JOB para identificar JOB envolvido no Blocking
************************************************************************/

CREATE FUNCTION [dbo].[udf_sysjobs_getprocessid](@job_id UNIQUEIDENTIFIER)
RETURNS VARCHAR(8)
AS
BEGIN
RETURN (SUBSTRING(LEFT(@job_id,8),7,2) +
SUBSTRING(LEFT(@job_id,8),5,2) +
SUBSTRING(LEFT(@job_id,8),3,2) +
SUBSTRING(LEFT(@job_id,8),1,2))
END
GO

/***********************************************************************
 SP identifica Blocking e alimenta tabela "DBA_Monitora_Hist_Bloking"
 - Criar JOB executando a cada 30 minutos "_DBA - Monitora Blocking"
 exec DBA_sp_Admin_BlockingHTML @Empresa = 'SQL Server Expert', @ProfileDatabaseMail = 'Profile_SMTP', @Operador = 'DBA', @LockWaitLimite = 60
************************************************************************/

CREATE OR ALTER PROC dbo.DBA_sp_Admin_BlockingHTML
@Empresa VARCHAR(1000) = 'SQL Server Expert',
@LockWaitLimite BIGINT = 60, -- em segundos

@ProfileDatabaseMail VARCHAR(2000) = 'Profile_SMTP',
@Operador VARCHAR(2000) = 'DBA'
AS
SET NOCOUNT ON

DECLARE @TableHead VARCHAR(MAX),@TableTail VARCHAR(MAX), @Subject VARCHAR(2000), @QtdLinhas int 
DECLARE @TableJOB VARCHAR(MAX)
DECLARE @Body VARCHAR(MAX), @BodyJOB VARCHAR(MAX)
DECLARE @SQLversion VARCHAR(MAX), @Email_TO VARCHAR(2000)

SELECT @Email_TO = email_address FROM msdb.dbo.sysoperators WHERE name = @Operador

SELECT @SQLversion = LEFT(@@VERSION,25) + ' - Build '
+ CAST(SERVERPROPERTY('productversion') AS VARCHAR) + ' - ' 
+ CAST(SERVERPROPERTY('productlevel') AS VARCHAR) + ' (' 
+ CAST(SERVERPROPERTY('edition') AS VARCHAR) + ')'

SET @TableTail = '</body></html>';
SET @TableHead = '<html><head>' +
			'<style>' +
			'td {border: solid black 1px;padding-LEFT:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:9pt;} ' +
			'</style>' +
			'</head>' +
			'<body>' + 
			'<P style=font-size:18pt;" ><B>Servidor ' + @@SERVERNAME + '</B></P>' +
			'<P style=font-size:12pt;" >' + @SQLversion + '</P><br>'

SET @Body = @TableHead

DECLARE @DataHora DATETIME
SET @DataHora = GETDATE()

-- Inclui em tabela com Historico de Blocking
insert dbo.DBA_Monitora_Hist_Blocking 

SELECT @DataHora, spid AS SPID, 'RAIZ' AS Status, waittime/1000 AS TempoEspera_Seg, blocked AS SPID_Blocking,
DB_NAME(sp.dbid) Banco,ISNULL(hostname,'N/A') Computador,
CASE WHEN sp.nt_domain IS NULL OR sp.nt_domain = '' THEN 'N/A' ELSE RTRIM(sp.nt_domain) + '/' + nt_username END AS UsuarioWindows, loginame AS LoginSQL, 

CASE 
WHEN s.PROGRAM_NAME like 'SQLAgent - TSQL JobStep (Job%' 
THEN (SELECT 'JOB: ' + MAX(name) + ' (' + REPLACE( SUBSTRING(s.PROGRAM_NAME,CHARINDEX(': Step',s.PROGRAM_NAME)+2,100) ,')','') + ')' FROM msdb.dbo.sysjobs WHERE dbo.udf_sysjobs_getprocessid(job_id) = SUBSTRING(s.PROGRAM_NAME,32,8) )
ELSE s.PROGRAM_NAME
END AS Aplicacao, 

s.client_interface_name AS AppInterface,
open_tran AS QtdTransacoes, cmd AS TipoComando, last_batch AS UltimoTSQL,qt.text AS InstrucaoTSQL, 'N' AS Email
,qt.encrypted

FROM sys.sysprocesses sp 
LEFT JOIN sys.dm_exec_sessions s ON s.SESSION_ID = sp.spid
OUTER APPLY sys.dm_exec_sql_text(sp.sql_handle) AS qt
WHERE spid IN (SELECT distinct blocked FROM sys.sysprocesses WHERE blocked > 0) AND blocked = 0

UNION 

SELECT @DataHora, spid AS SPID, 'BLOCK' AS Status, waittime/1000 AS TempoEspera_Seg, blocked AS SPID_Blocking,
DB_NAME(sp.dbid) Banco,ISNULL(hostname,'N/A') Computador,
CASE WHEN sp.nt_domain IS NULL OR sp.nt_domain = '' THEN 'N/A' ELSE RTRIM(sp.nt_domain) + '/' + nt_username END AS UsuarioWindows, loginame AS LoginSQL, 

CASE 
WHEN s.PROGRAM_NAME like 'SQLAgent - TSQL JobStep (Job%' 
THEN (SELECT 'JOB: ' + MAX(name) + ' (' + REPLACE( SUBSTRING(s.PROGRAM_NAME,CHARINDEX(': Step',s.PROGRAM_NAME)+2,100) ,')','') + ')' FROM msdb.dbo.sysjobs WHERE dbo.udf_sysjobs_getprocessid(job_id) = SUBSTRING(s.PROGRAM_NAME,32,8) )
ELSE s.PROGRAM_NAME
END AS Aplicacao, 
 
s.client_interface_name AS AppInterface,
open_tran AS QtdTransacoes, cmd AS TipoComando, last_batch AS UltimoTSQL,qt.text AS InstrucaoTSQL, 'N' AS Email
,qt.encrypted

FROM sys.sysprocesses sp 
LEFT JOIN sys.dm_exec_sessions s ON s.SESSION_ID = sp.spid
OUTER APPLY sys.dm_exec_sql_text(sp.sql_handle) AS qt
WHERE  spid > 50 AND blocked > 0 AND waittime > (@LockWaitLimite * 1000) -- 6 segundos em milisegundos
-- FIM Inclui



IF (SELECT MAX(TempoEspera_Seg) FROM dbo.DBA_Monitora_Hist_Blocking WHERE Email = 'N') >= @LockWaitLimite BEGIN
	SET @TableJOB = '<P style=font-size:14pt;" ><B>- Processos em Blocking</B></P>' +
				'<table cellpadding=0 cellspacing=0 border=0>' +
				'<tr bgcolor=#87CEEB>' + 
				'<td align=center><b>DataHora_Coleta</b></td>' + 
				'<td align=center><b>SPID</b></td>' + 
				'<td align=center><b>Status</b></td>' + 
				'<td align=center><b>Tempo Espera Seg</b></td>' + 
				'<td align=center><b>SPID Blocking</b></td>' + 
				'<td align=center><b>Banco</b></td>' + 
				'<td align=center><b>Computador</b></td>' + 
				'<td align=center><b>Usuario Windows</b></td>' + 
				'<td align=center><b>Login SQL</b></td>' + 
				'<td align=center><b>Aplicacao</b></td>' + 
				'<td align=center><b>App Interface</b></td>' + 
				'<td align=center><b>Qtd Transacoes</b></td>' + 
				'<td align=center><b>Tipo Comando</b></td>' + 
				'<td align=center><b>UltimoTSQL</b></td></tr>';				

	SELECT @BodyJOB = (SELECT Row_Number() Over(Order By SPID_Blocking, SPID) % 2 AS [TRRow], convert(VARCHAR(10), DataHora_Coleta,103) + ' ' + convert(VARCHAR(8), DataHora_Coleta,114) AS [TD], 
	SPID AS [TD], Status AS [TD], TempoEspera_Seg AS [TD], SPID_Blocking AS [TD], Banco AS [TD], Computador AS [TD], UsuarioWindows AS [TD], LoginSQL AS [TD], Aplicacao AS [TD], AppInterface AS [TD], 
	QtdTransacoes AS [TD], TipoComando AS [TD], convert(VARCHAR(10), UltimoTSQL,103) + ' ' + convert(VARCHAR(8), UltimoTSQL,114) AS [TD]
	FROM dbo.DBA_Monitora_Hist_Blocking WHERE Email = 'N'
	ORDER BY SPID_Blocking, SPID
	FOR XML raw('tr'),elements)

	SET @BodyJOB = REPLACE(@BodyJOB, '_x0020_', space(1))
	SET @BodyJOB = REPLACE(@BodyJOB, '_x003D_', '=')
	SET @BodyJOB = REPLACE(@BodyJOB, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#F0F0F0>')
	SET @BodyJOB = REPLACE(@BodyJOB, '<TRRow>0</TRRow>', '')
	SET @BodyJOB = @BodyJOB + '</table><p> </p><br>'
	SET @Body = @Body + @TableJOB + @BodyJOB
	
	SET @Body = @Body + @TableTail
	SET @Subject = @Empresa + ': BLOCKING Servidor ' + @@SERVERNAME + ' do dia ' + CONVERT(VARCHAR(30),GETDATE(),103)

	EXEC msdb.dbo.sp_send_dbmail
	@recipients=@Email_TO,
	@subject = @Subject,
	@body = @Body,
	@body_format = 'HTML' ,
	@profile_name=@ProfileDatabaseMail

	UPDATE dbo.DBA_Monitora_Hist_Blocking SET Email = 'S' WHERE Email = 'N' 
END
ELSE
	delete dbo.DBA_Monitora_Hist_Blocking WHERE Email = 'N'
GO
/********************************************* FIM SP ****************************************************************/