/*****************************************
 Hands On: Alerta Boot Servidor SQL Server
******************************************/

USE master
GO

DECLARE @Empresa VARCHAR(200) = 'SQL Server Expert'
DECLARE @ProfileSMTP VARCHAR(200) = 'Profile_SMTP'
DECLARE @Operador VARCHAR(200) = 'DBA'

DECLARE @TableHead VARCHAR(MAX),@TableTail VARCHAR(MAX), @Subject VARCHAR(2000), @Body VARCHAR(MAX)
DECLARE @Email_TO VARCHAR(2000), @Servidor VARCHAR(2000), @SQLNo VARCHAR(2000)

SELECT @Servidor = @@SERVERNAME
SET @TableTail = '</body></html>';
SET @TableHead = '<html><head>' +
			'<style>' +
			'td {border: solid black 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:9pt;} ' +
			'</style>' +
			'</head>' +
			'<body>' + 
			'<P style=font-size:18pt;" ><B>Servidor ' + @Servidor +  ' Reiniciou</B></P>'


/**************** Monta HTML Final e envia email ********************/

SET @Body = @TableHead
SET @Body = @Body + @TableTail
--Select @Body

SELECT @Email_TO = email_address FROM msdb.dbo.sysoperators WHERE name = @Operador
SET @Subject = @Empresa + ': ' + @@SERVERNAME + ' - SQL Server REINICIOU no dia ' + CONVERT(VARCHAR(30),getdate(),103)

EXEC msdb.dbo.sp_send_dbmail
@recipients=@Email_TO,
@subject = @Subject,
@body = @Body,
@body_format = 'HTML' ,
@profile_name= @ProfileSMTP
GO