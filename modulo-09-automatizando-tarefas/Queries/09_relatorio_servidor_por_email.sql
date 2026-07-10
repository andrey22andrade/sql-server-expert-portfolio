/********************************************
 Relatório diário Servidor SQL Server em HTML
 Parâmetros
 ********************************************/

USE DBA
GO

DROP TABLE IF EXISTS dbo.DBA_BackupExcluir
GO
CREATE TABLE dbo.DBA_BackupExcluir(
Nomebanco sysname NOT NULL CONSTRAINT pk_DBA_BackupExcluir PRIMARY KEY)
GO

-- exec DBA_sp_RelatorioHTML @Empresa = 'SQL Server Expert', @ProfileDatabaseMail = 'Profile_SMTP', @Operador = 'DBA'
CREATE or ALTER PROC dbo.DBA_sp_RelatorioHTML
@Empresa VARCHAR(1000) = 'SQL Server Expert',
@DiscoLimite BIGINT = 20000,
@MemLimite BIGINT = 2000,
@BancosSemBackupLimite INT = 2,
@ProfileDatabaseMail VARCHAR(2000) = 'Profile_SMTP',
@Operador VARCHAR(2000) = 'DBA'
as
SET nocount on

DECLARE @TableHead VARCHAR(MAX),@TableTail VARCHAR(MAX), @Subject VARCHAR(2000), @QtdLinhas INT 
DECLARE @TableJOB VARCHAR(MAX), @TableManutBD VARCHAR(MAX), @TableDivBD VARCHAR(MAX)
DECLARE @TableDisco VARCHAR(MAX), @TableMemoria VARCHAR(MAX), @TableSemBackup VARCHAR(MAX)
DECLARE @Body VARCHAR(MAX), @BodyJOB VARCHAR(MAX), @BodyManutBD VARCHAR(MAX), @BodyDivBD VARCHAR(MAX)
DECLARE @BodyDisco VARCHAR(MAX), @BodyMemoria VARCHAR(MAX)
DECLARE @SQLversion VARCHAR(MAX), @Email_TO VARCHAR(2000), @Servidor VARCHAR(2000), @SQLNo VARCHAR(2000)


SELECT @Email_TO = email_address FROM msdb.dbo.sysoperators WHERE name = @Operador

SELECT @SQLversion = left(@@VERSION,25) + ' - Build '
+ CAST(SERVERPROPERTY('productversion') AS VARCHAR) + ' - ' 
+ CAST(SERVERPROPERTY('productlevel') AS VARCHAR) + ' (' 
+ CAST(SERVERPROPERTY('edition') AS VARCHAR) + ')'

SELECT @Servidor = @@SERVERNAME

SET @TableTail = '</body></html>';
SET @TableHead = '<html><head>' +
			'<style>' +
			'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:9pt;} ' +
			'</style>' +
			'</head>' +
			'<body>' + 
			'<P style=font-size:18pt;" ><B>Servidor ' + @Servidor +  '</B></P>' +
			'<P style=font-size:12pt;" >' + @SQLversion + '</P>'

SET @Body = @TableHead

/*******************
 JOBs com falha
********************/
CREATE TABLE #Relat_JOBs (
JOB VARCHAR(1000) NULL,
[DataHora Inicio] VARCHAR(30) NULL,
[Status] VARCHAR(20) NULL,
Duracao VARCHAR(30) null,
Mensagem nvarchar(4000) NULL,
ProximaExecucao VARCHAR(30) NULL)

INSERT INTO #Relat_JOBs
SELECT sJOB.name AS JOB,
CASE WHEN sJOBH.run_date IS NULL OR sJOBH.run_time IS NULL THEN NULL
     ELSE CAST(CAST(sJOBH.run_date AS CHAR(8)) + ' ' + STUFF(STUFF(RIGHT('000000' + CAST(sJOBH.run_time AS VARCHAR(6)),6),3,0,':'),6,0,':') AS DATETIME) END AS DataHora,
CASE sJOBH.run_status
     WHEN 0 THEN 'Falha'
     WHEN 1 THEN 'Sucesso'
     WHEN 2 THEN 'Retry'
     WHEN 3 THEN 'Cancelado'
     WHEN 4 THEN 'Em Execução' 
     ELSE 'N/A' END AS [Status],
STUFF(STUFF(RIGHT('000000' + CAST(sJOBH.run_duration AS VARCHAR(6)),6),3,0,':'),6,0,':') AS [Duracao (HH:MM:SS)],
sJOBH.message AS Mensagem,
CASE sJOBSCH.NextRunDate WHEN 0 THEN NULL
     ELSE CAST(CAST(sJOBSCH.NextRunDate AS CHAR(8)) + ' ' + STUFF(STUFF(RIGHT('000000' + CAST(sJOBSCH.NextRunTime AS VARCHAR(6)),6),3,0,':'),6,0,':') AS DATETIME) END AS ProximaExecucao
FROM msdb.dbo.sysjobs AS sJOB LEFT JOIN (
SELECT job_id,MIN(next_run_date) AS NextRunDate,MIN(next_run_time) AS NextRunTime
FROM msdb.dbo.sysjobschedules GROUP BY job_id) AS sJOBSCH ON sJOB.job_id = sJOBSCH.job_id
LEFT JOIN (
SELECT job_id,run_date,run_time,run_status,run_duration,[message],
ROW_NUMBER() OVER (PARTITION BY job_id ORDER BY run_date DESC, run_time DESC) AS RowNumber
FROM msdb.dbo.sysjobhistory WHERE step_id = 0) AS sJOBH ON sJOB.job_id = sJOBH.job_id AND sJOBH.RowNumber = 1
WHERE 1=1
and sJOBH.run_status <> 1
and sJOB.enabled = 1
-- SELECT * FROM #Relat_JOBs

IF @@rowcount > 0 begin
	SET @TableJOB = '<P style=font-size:14pt;><B>- SQL Server JOBs</B></P>' +
				'<TABLE cellpadding=0 cellspacing=0 border=0>' +
				'<tr bgcolor=#87CEEB>' + 
				'<td align=center><b>JOB</b></td>' + 
				'<td align=center><b>DataHora Inicio</b></td>' + 
				'<td align=center><b>Status</b></td>' + 
				'<td align=center><b>Duracao (HH:MM:SS)</b></td>' + 
				'<td align=center><b>Mensagem</b></td>' + 
				'<td align=center><b>Proxima Execucao</b></td></tr>';
				
	SELECT @BodyJOB = (SELECT Row_Number() Over(Order By JOB) % 2 As [TRRow],
	JOB as [TD],isnull([DataHora Inicio],'N/A') as [TD],[Status] as [TD],isnull([Duracao],'N/A') as [TD],isnull(Mensagem,'N/A') as [TD],isnull(ProximaExecucao,'N/A') as [TD]
	FROM #Relat_JOBs ORDER BY JOB
	FOR XML raw('tr'),elements)

	SET @BodyJOB = Replace(@BodyJOB, '_x0020_', space(1))
	SET @BodyJOB = Replace(@BodyJOB, '_x003D_', '=')
	SET @BodyJOB = Replace(@BodyJOB, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#F0F0F0>')
	SET @BodyJOB = Replace(@BodyJOB, '<TRRow>0</TRRow>', '')
	SET @BodyJOB = Replace(@BodyJOB, '<TD>Falha</TD>', '<TD align=center><font color = "#ff0000">Falha</font></TD>')
--	SET @BodyJOB = Replace(@BodyJOB, '<TD>Sucesso</TD>', '<TD align=center><font color = "#0000ff">Sucesso</font></TD>')

	SET @BodyJOB = @BodyJOB + '</TABLE><p> </p><br>'
	SET @Body = @Body + @TableJOB + @BodyJOB
END

drop TABLE #Relat_JOBs

/**************************************
 Bancos sem Backup nos últimos X dias 
***************************************/
DECLARE @BancosSemBackup VARCHAR(MAX)
/* TYPE:
D = Database 
I = Differential database 
L = Log 
F = File or filegroup 
G =Differential file 
P = Partial 
Q = Differential partial 
*/
;WITH BancosSemBackup as (
SELECT NAME as Banco FROM sys.databases
WHERE NAME not in ('TEMPDB','Model','DBA')  
and not EXISTS (SELECT * FROM dbo.DBA_BackupExcluir WHERE Nomebanco = NAME)
--and name not in (SELECT secondary_database FROM msdb.dbo.log_shipping_secondary_databases)
and source_database_id is null 
and NAME not in (SELECT DISTINCT database_name 
FROM msdb..backupset
WHERE backup_start_date > DATEADD(DAY,(@BancosSemBackupLimite * -1),GETDATE()) AND  TYPE = 'D')
and state_desc = 'ONLINE' and source_database_id is null)

SELECT @BancosSemBackup = COALESCE(@BancosSemBackup + ', ', '') + Banco FROM BancosSemBackup
--SELECT @BancosSemBackup

IF @BancosSemBackup is not null begin
	SET @TableSemBackup = '<P style=font-size:14pt;><B>- Bancos sem backup nos últimos ' + 
	ltrim(str(@BancosSemBackupLimite)) + ' dias:</B> ' + @BancosSemBackup + '</P>' 
	
	SET @Body = @Body + @TableSemBackup
END


/*********************************
 Analisa espaço livre nos Discos 
**********************************/
CREATE TABLE #RelatDrive (Drive VARCHAR(10) null,[EspacoLivre MB] BIGINT null)

INSERT #RelatDrive (Drive, [EspacoLivre MB]) EXEC master.dbo.xp_fixeddrives;


SET @TableDisco = '<P style=font-size:14pt;><B>- Drives com pouco espaco livre</B></P>' +
			'<TABLE cellpadding=0 cellspacing=0 border=0>' +
			'<tr bgcolor=#87CEEB>' + 
			'<td align=center><b>Drive</b></td>' + 
			'<td align=center><b>Espaco Livre MB</b></td></tr>';

SELECT @QtdLinhas = COUNT(*) FROM #RelatDrive WHERE Drive not in ('M','Q') and [EspacoLivre MB] < @DiscoLimite 
IF @QtdLinhas > 0 begin
			
	SELECT @BodyDisco = (SELECT Drive as [TD],[EspacoLivre MB] as [TD] FROM #RelatDrive WHERE Drive not in ('M','Q') and [EspacoLivre MB] < @DiscoLimite order by Drive FOR XML raw('tr'),elements)

	SET @BodyDisco = Replace(@BodyDisco, '_x0020_', space(1))
	SET @BodyDisco = Replace(@BodyDisco, '_x003D_', '=')
	SET @BodyDisco = Replace(@BodyDisco, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#F0F0F0>')
	SET @BodyDisco = Replace(@BodyDisco, '<TRRow>0</TRRow>', '')
	SET @BodyDisco = @BodyDisco + '</TABLE><p> </p>'
	SET @Body = @Body + @TableDisco + @BodyDisco
END

drop TABLE #RelatDrive


/*******************
 Analisa Memoria 
********************/
-- Cria tabela para relatório de JOBs de Backup
-- drop TABLE ##RelatDrive
IF left(@@VERSION,25) <> 'Microsoft SQL Server 2005' begin
	CREATE TABLE #RelatMemoria ([Memoria Total MB] BIGINT NULL,[Memoria Disponivel MB] BIGINT NULL,[% Livre] decimal(5,2) NULL)

	INSERT INTO #RelatMemoria
	SELECT total_physical_memory_kb/1024 as "Memoria Total MB",
		   available_physical_memory_kb/1024 as "Memoria Disponivel MB",
		   available_physical_memory_kb/(total_physical_memory_kb*1.0)*100 AS "% Livre"
	FROM sys.dm_os_sys_memory

	SET @TableMemoria = '<P style=font-size:14pt;><B>- Servidor pouca memoria livre</B></P>' +
				'<TABLE cellpadding=0 cellspacing=0 border=0>' +
				'<tr bgcolor=#87CEEB>' + 
				'<td align=center><b>Memoria Total MB</b></td>' + 
				'<td align=center><b>Memoria Disponivel MB</b></td>' + 
				'<td align=center><b>% Livre</b></td></tr>';

	DECLARE @MemLivre BIGINT  
	SELECT @MemLivre = [Memoria Disponivel MB] FROM #RelatMemoria    

	IF (@MemLivre < @MemLimite) begin

		SELECT @BodyMemoria = (SELECT [Memoria Total MB] as TD,[Memoria Disponivel MB] as TD,[% Livre] as TD FROM #RelatMemoria FOR XML raw('tr'),elements)

		SET @BodyMemoria = Replace(@BodyMemoria, '_x0020_', space(1))
		SET @BodyMemoria = Replace(@BodyMemoria, '_x003D_', '=')
		SET @BodyMemoria = Replace(@BodyMemoria, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#F0F0F0>')
		SET @BodyMemoria = Replace(@BodyMemoria, '<TRRow>0</TRRow>', '')
		SET @BodyMemoria = @BodyMemoria + '</TABLE><p> </p>'
		SET @Body = @Body + @TableMemoria + @BodyMemoria
	END
	DROP TABLE #RelatMemoria
END


/***********************************
 Monta HTML Final e envia email 
************************************/
SET @Body = @Body + @TableTail
--print @Body

IF @Body not like '%<TABLE%'
	SET @Body = '<br><P style=font-size:14pt;" ><B>Servidor sem ocorrências.</B></P>'

SET @Subject = @Empresa + ': Relatório ' + @@SERVERNAME + ' do dia ' + CONVERT(VARCHAR(30),GETDATE(),103)

EXEC msdb.dbo.sp_send_dbmail
@recipients=@Email_TO,
@subject = @Subject,
@body = @Body,
@body_format = 'HTML' ,
@profile_name=@ProfileDatabaseMail
GO

/************************************* Fim SP ********************************************/