/**************************************************************************************************
 Alerta para latência de IO no SQL Server
 
 Utiliza sys.xp_readerrorlog, parâmetros:
 1) Valor que identifica o Log que deve ser retornado - 0 = corrente, 1 = Arquivo #1, 2 = Arquivo #2, etc...
 2) Tipo do Log - 1 or NULL = Log SQL Server, 2 = Log SQL Agent
 3) Primeira pesquisa de string
 4) Segunda pesquisa de string
 5) Pesquisa a partir de uma data/hora
 6) Pesquisa até uma data/hora
 7) Ordem: N'asc' = ascending, N'DESC' = descending

 Exemplo para retornar ocorrências de latência no Log corrente do SQL Server:

	EXEC sys.xp_readerrorlog 0,1,N'I/O requests taking longer than 15 seconds to complete',NULL,NULL,NULL,N'DESC'
 
 Artigo que relata o problema:
 https://blogs.msdn.microsoft.com/sqlsakthi/2011/02/09/troubleshooting-sql-server-io-requests-taking-longer-than-15-seconds-io-stalls-disk-latency/

****************************************************************************************************/
USE master
GO

SET NOCOUNT ON

DECLARE @NomeBanco VARCHAR(2000), @state_desc VARCHAR(200) 
DECLARE @command VARCHAR(4000)
DECLARE @Empresa VARCHAR(1000) = 'SQL Server Expert'
DECLARE @ProfileDatabaseMail VARCHAR(2000) = 'Profile_SMTP'
DECLARE @Operador VARCHAR(2000) = 'DBA'
DECLARE @QtdPaginas INT = 0

-- ENVIA EMAIL
DECLARE @TableHead VARCHAR(max),@TableTail VARCHAR(max), @Subject VARCHAR(2000), @QtdLinhas INT 
DECLARE @TableJOB VARCHAR(max)
DECLARE @Body VARCHAR(max), @BodyJOB VARCHAR(max), @BodyManutBD VARCHAR(max), @BodyDisco VARCHAR(max), @BodyMemoria VARCHAR(max)
DECLARE @SQLversion VARCHAR(max), @Email_TO VARCHAR(2000), @Servidor VARCHAR(2000)

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
			'<P style=font-size:12pt;" >' + @SQLversion + '</P><br>'

SET @Body = @TableHead

DECLARE @DataSinc DATETIME
SET @DataSinc = dateadd(dd,-1,getdate())

CREATE TABLE #tmp_ErroLog (
LogDate DATETIME NULL,
ProcessInfo NVARCHAR(200) NULL,
Msg NVARCHAR(max))


INSERT #tmp_ErroLog
EXEC sys.xp_readerrorlog 0,1,N'I/O requests taking longer than 15 seconds to complete',NULL,NULL,NULL,N'DESC'

DELETE #tmp_ErroLog WHERE LogDate < (GETDATE()-2)

IF EXISTS (SELECT * FROM  #tmp_ErroLog) begin

	SET @TableJOB = '<P style=font-size:14pt;" ><B>Quantidade de ocorrências de latência de IO por dia</B></P>' +
				'<table cellpadding=0 cellspacing=0 border=0>' +
				'<tr bgcolor=#87CEEB>' + 
				'<td align=center><b>Data</b></td>' + 
				'<td align=center><b>Quantidade</b></td></tr>';

	SELECT @BodyJOB = (SELECT Row_Number() Over(ORDER BY CAST(LogDate AS DATE) DESC) % 2 AS [TRRow],
	CAST(LogDate AS DATE) AS [TD], SUM(CAST(substring(Msg,27,CHARINDEX ('occurrence',Msg)-28) AS BIGINT)) AS [TD]
	FROM #tmp_ErroLog
	GROUP BY CAST(LogDate AS DATE)
	ORDER BY 1 DESC
	FOR XML raw('tr'),elements)

	SET @BodyJOB = Replace(@BodyJOB, '_x0020_', space(1))
	SET @BodyJOB = Replace(@BodyJOB, '_x003D_', '=')
	SET @BodyJOB = Replace(@BodyJOB, '<tr><TRRow>1</TRRow>', '<tr bgcolor=#F0F0F0>')
	SET @BodyJOB = Replace(@BodyJOB, '<TRRow>0</TRRow>', '')
	SET @BodyJOB = @BodyJOB + '</table><p> </p><br>'
	SET @Body = @Body + @TableJOB + @BodyJOB

    /**************** Monta HTML Final e envia email ********************/
    SET @Body = @Body + @TableTail
    --SELECT @Body


    SET @Subject = @Empresa + ': Latência IO - ' + @@SERVERNAME + ' do dia ' + CONVERT(VARCHAR(30),GETDATE(),103)

	EXEC msdb.dbo.sp_send_dbmail
	@recipients=@Email_TO,
	@subject = @Subject,
	@body = @Body,
	@body_format = 'HTML' ,
	@profile_name=@ProfileDatabaseMail
END

DROP TABLE #tmp_ErroLog
GO