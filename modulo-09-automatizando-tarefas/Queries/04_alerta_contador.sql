/***********************************
 SQL Server Agent Alertas Contadores
************************************/

USE master
GO

/***************************************
 Cria Banco AlertaDB para o Hands On
****************************************/

DROP DATABASE IF EXISTS AlertaDB
GO

CREATE DATABASE AlertaDB
GO

BACKUP DATABASE AlertaDB TO DISK = 'C:\_HandsOn_AdmSQL\Backup\AlertaDB.bak' WITH FORMAT, COMPRESSION
GO

-- Define o tamanho máximo do arquivo de Log para 70MB
ALTER DATABASE AlertaDB MODIFY FILE (name = 'AlertaDB_log', maxsize = 70mb)
GO

/*******************************************************
 Alerta para código de erro 9002, arquivo de Log cheio
********************************************************/

-- Cria operador
EXEC msdb.dbo.sp_add_operator @name=N'DBA', 
@enabled=1, 
@weekday_pager_start_time=90000, 
@weekday_pager_end_time=180000, 
@saturday_pager_start_time=90000, 
@saturday_pager_end_time=180000, 
@sunday_pager_start_time=90000, 
@sunday_pager_end_time=180000, 
@pager_days=0, 
@email_address=N'dsai.erro@gmail.com', 
@category_name=N'[Uncategorized]'
GO


-- Cria Alerta para o erro 9002 Arquivo de log Cheio
EXEC msdb.dbo.sp_add_alert @name = 'Transction Log FULL', @message_id = 9002,@delay_between_responses = 0 
EXEC msdb.dbo.sp_add_notification @alert_name = 'Transction Log FULL', @operator_name = 'DBA', @notification_method = 1

/************************************************
 Gera atividade para encher o arquivo de Log
*************************************************/
CREATE TABLE AlertaDB.dbo.Cliente (
Cliente_ID INT NOT NULL IDENTITY,
Nome CHAR(6000) NOT NULL)
GO

-- Gera atividade
DECLARE @i INT = 1
WHILE @i <= 10000 BEGIN
	INSERT AlertaDB.dbo.Cliente VALUES ('Jose')
	DELETE AlertaDB.dbo.Cliente WHERE Nome = 'Jose'
	SET @i += 1
END
GO

/********************************
 Criar JOB para Backup do Log
*********************************/
DECLARE @Arquivo VARCHAR(4000)
SET @Arquivo = 'C:\_HandsOn_AdmSQL\Backup\AlertaDB_' + CONVERT(CHAR(8),GETDATE(),112)+ '_H' + REPLACE(convert(CHAR(8),getdate(),108),':','') + '.trn'
BACKUP LOG AlertaDB TO DISK = @Arquivo WITH FORMAT, COMPRESSION

/*******************************************************
 Alerta para contador do System Monitor
********************************************************/

-- Aumenta o limite máximo de crescimento do arquivo de Log para 100MB
ALTER DATABASE AlertaDB MODIFY FILE (name = 'AlertaDB_log', size = 100mb ,maxsize = 100mb)

-- Alerta para contador "Percent Log Used"
EXEC msdb.dbo.sp_add_alert @name = 'Ocupacao Arq Log', 
@enabled = 1, 
@delay_between_responses = 0, 
@include_event_description_in = 0, 
@performance_condition = 'Databases|Percent Log Used|AlertaDB|>|60'
GO

EXEC msdb.dbo.sp_add_notification @alert_name=N'Ocupacao Arq Log', @operator_name=N'Landry', @notification_method = 1

-- Gera atividade para encher o arquivo de Log
DECLARE @i INT = 1
WHILE @i <= 2000 BEGIN
	INSERT AlertaDB.dbo.Cliente VALUES ('Jose')
	DELETE AlertaDB.dbo.Cliente WHERE Nome = 'Jose'
	SET @i += 1
END
GO

/*********************
 Exclui Objetos
**********************/
EXEC msdb.dbo.sp_delete_alert @name = 'Ocupacao Arq Log'
EXEC msdb.dbo.sp_delete_alert @name = 'Transction Log FULL'

DROP DATABASE IF EXISTS AlertaDB
GO