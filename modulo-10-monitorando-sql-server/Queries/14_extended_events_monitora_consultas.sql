/*********************************************
 Monitora Consultas
 - Cria tabela para armazenar dados capturados
 - Cria Extende Events
 - Importa dados 
**********************************************/

USE DBA
GO

/*******************************************
 Cria Tabela para receber dados monitorados
 - 1 minuto = 60 segundos = 60.000 Milissegundos = 60.000.000 microsegundos
 - Duration em microsegundos
 - CPU em milesegundos
********************************************/

DROP TABLE IF EXISTS DBA.dbo.DBA_Query_Tuning
GO

CREATE TABLE DBA.dbo.DBA_Query_Tuning (
Evento_ID INT NOT NULL identity primary key,
DataHora DATETIME NULL,
Evento VARCHAR(200) NULL,
TempoExec BIGINT NULL,
TempoExec_Seg BIGINT NULL,
TempoCPU BIGINT NULL,
TempoCPU_Seg BIGINT NULL,
QtdLinhas INT NULL,
LeiturasLogicas_Kb BIGINT NULL,
LeiturasFisicas_Kb BIGINT NULL,
Escritas_Kb INT NULL,
Usuario VARCHAR(200) NULL,
Host VARCHAR(200) NULL,
Aplicacao VARCHAR(200) NULL,
SPID INT NULL,
EventoID INT NULL,
Instancia VARCHAR(200) NULL,
Banco VARCHAR(200) NULL,
Comando VARCHAR(max) NULL,
Comando_XML XML NULL)
GO

/*****************************************************
 Unidade de tempo pode variar de acordo com o Evento
******************************************************/

SELECT p.name package_name,
o.name event_name,
c.name event_field,
DurationUnit= CASE
WHEN c.description LIKE '%milli%' 
THEN SUBSTRING(c.description, CHARINDEX('milli', c.description),12)
WHEN c.description LIKE '%micro%' 
THEN SUBSTRING(c.description, CHARINDEX('micro', c.description),12)
ELSE NULL END,
c.type_name field_type,
c.column_type column_type

FROM sys.dm_xe_objects o
JOIN sys.dm_xe_packages p ON o.package_guid = p.guid
JOIN sys.dm_xe_object_columns c ON o.name = c.object_name
WHERE o.object_type = 'event'
AND c.name ='duration'
--AND o.name in ('rpc_completed','sql_batch_completed')
ORDER BY event_name
GO

/**************************************************
 Stored Procedure spu_DBA_Query_Tuning_Start
 - Cria Captura de Consultas
***************************************************/

CREATE OR ALTER PROC dbo.spu_DBA_Query_Tuning_Start
@Caminho NVARCHAR(1000) = N'C:\_HandsOn_AdmSQL\_PerfMonitor',
@Tempo INT = 30000000, -- microseconds 60000000 = minuto 1
@Banco NVARCHAR(128) = NULL
AS
SET NOCOUNT ON

DECLARE @Arquivo NVARCHAR(2000)
SET @Arquivo = @Caminho + '\MonitoraConsultas_' + CONVERT(VARCHAR(8),GETDATE(),112) + '.xel'

-- DROP EVENT SESSION DBA_Monitora_Consultas ON SERVER 
DECLARE @TSQL NVARCHAR(2000)

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'DBA_Monitora_Consultas') BEGIN
	ALTER EVENT SESSION DBA_Monitora_Consultas ON SERVER STATE = STOP
	DROP EVENT SESSION DBA_Monitora_Consultas ON SERVER
END

IF @Banco is NULL
SET @TSQL = N'CREATE EVENT SESSION DBA_Monitora_Consultas ON SERVER 
ADD EVENT sqlserver.rpc_completed(

    ACTION(package0.collect_cpu_cycle_time,package0.collect_system_time,package0.event_sequence,sqlos.task_time,sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.database_name,sqlserver.nt_username,sqlserver.server_instance_name,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
	WHERE sqlserver.database_name <> ''master'' AND sqlserver.database_name <> ''msdb'' AND sqlserver.database_name <> ''tempdb'' 
	AND sqlserver.database_name <> ''ReportServer'' AND sqlserver.database_name <> ''ReportServerTempDB'' AND duration >= ' + LTRIM(STR(@Tempo)) + '),

ADD EVENT sqlserver.sql_batch_completed (
    ACTION(package0.collect_cpu_cycle_time,package0.collect_system_time,package0.event_sequence,sqlos.task_time,sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.database_name,sqlserver.nt_username,sqlserver.server_instance_name,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
	WHERE sqlserver.database_name <> ''master'' AND sqlserver.database_name <> ''msdb'' AND sqlserver.database_name <> ''tempdb'' 
	AND sqlserver.database_name <> ''ReportServer'' AND sqlserver.database_name <> ''ReportServerTempDB''  AND duration >= ' + LTRIM(STR(@Tempo)) + ')

ADD TARGET package0.event_file(SET filename=N''' + @Arquivo + ''',max_file_size=(100),max_rollover_files=(20))
WITH (STARTUP_STATE=OFF)'

ELSE
SET @TSQL = N'CREATE EVENT SESSION DBA_Monitora_Consultas ON SERVER 
ADD EVENT sqlserver.rpc_completed(

    ACTION(package0.collect_cpu_cycle_time,package0.collect_system_time,package0.event_sequence,sqlos.task_time,sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.database_name,sqlserver.nt_username,sqlserver.server_instance_name,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
	WHERE sqlserver.database_name = ''' + @Banco + ''' AND duration >= ' + LTRIM(STR(@Tempo)) + '),

ADD EVENT sqlserver.sql_statement_completed(
    ACTION(package0.collect_cpu_cycle_time,package0.collect_system_time,package0.event_sequence,sqlos.task_time,sqlserver.client_app_name,sqlserver.client_connection_id,sqlserver.client_hostname,sqlserver.client_pid,sqlserver.database_name,sqlserver.nt_username,sqlserver.server_instance_name,sqlserver.session_id,sqlserver.session_nt_username,sqlserver.sql_text,sqlserver.username)
	WHERE sqlserver.database_name = ''' + @Banco + ''' AND duration >= ' + LTRIM(STR(@Tempo)) + ')

ADD TARGET package0.event_file(SET filename=N''' + @Arquivo + ''',max_file_size=(100),max_rollover_files=(20))
WITH (STARTUP_STATE=OFF)'

EXEC (@TSQL)

ALTER EVENT SESSION DBA_Monitora_Consultas ON SERVER STATE = START
GO
/******************************* FIM SP *************************************/

/**************************************************
 Stored Procedure spu_DBA_Query_Tuning_Stop
 - Cria Captura de Consultas
***************************************************/
CREATE OR ALTER PROC spu_DBA_Query_Tuning_Stop
@Caminho NVARCHAR(1000) = N'C:\_HandsOn_AdmSQL\_PerfMonitor'
AS
SET NOCOUNT ON

IF EXISTS (SELECT * FROM sys.server_event_sessions WHERE name = 'DBA_Monitora_Consultas') BEGIN
	ALTER EVENT SESSION DBA_Monitora_Consultas ON SERVER STATE = STOP
	DROP EVENT SESSION DBA_Monitora_Consultas ON SERVER
END

DECLARE @Arquivo NVARCHAR(2000) = @Caminho + N'\MonitoraConsultas_' + CONVERT(VARCHAR(8),GETDATE(),112) + '*.xel'

INSERT DBA.dbo.DBA_Query_Tuning
(DataHora, Evento, TempoExec, TempoExec_Seg, TempoCPU, TempoCPU_Seg, QtdLinhas, LeiturasLogicas_Kb, LeiturasFisicas_Kb, 
Escritas_Kb, Usuario, Host, Aplicacao, SPID, EventoID, Instancia, Banco, Comando, Comando_XML)

SELECT DataHora =  d.value(N'(/event/action[@name="collect_system_time"]/value)[1]', N'DATETIME')
,Evento = d.value(N'(/event/@name)[1]', N'VARCHAR(200)')
,TempoExec = d.value(N'(/event/data[@name="duration"]/value)[1]', N'BIGINT') -- Microsegundos
,TempoExec_Seg = d.value(N'(/event/data[@name="duration"]/value)[1]', N'BIGINT') / 1000000 -- Microsegundos
,TempoCPU = d.value(N'(/event/data[@name="cpu_time"]/value)[1]', N'BIGINT') -- Microsegundos
,TempoCPU_Seg = d.value(N'(/event/data[@name="cpu_time"]/value)[1]', N'BIGINT') / 1000000 -- Microsegundos
,QtdLinhas = d.value(N'(/event/data[@name="row_count"]/value)[1]', N'INT') 
,LeiturasLogicas_Kb = d.value(N'(/event/data[@name="logical_reads"]/value)[1]', N'BIGINT') * 8 -- Qtd de paginas 8k
,LeiturasFisicas_Kb = d.value(N'(/event/data[@name="physical_reads"]/value)[1]', N'BIGINT') * 8 -- Qtd de paginas 8k
,Escritas_Kb = d.value(N'(/event/data[@name="writes"]/value)[1]', N'INT') * 8
,Usuario = d.value(N'(/event/action[@name="username"]/value)[1]', N'VARCHAR(200)')
,Host = d.value(N'(/event/action[@name="client_hostname"]/value)[1]', N'VARCHAR(200)')
,Aplicacao = d.value(N'(/event/action[@name="client_app_name"]/value)[1]', N'VARCHAR(200)')
,SPID = d.value(N'(/event/action[@name="session_id"]/value)[1]', N'INT')
,EventoID = d.value(N'(/event/action[@name="event_sequence"]/value)[1]', N'INT')
,Instancia = d.value(N'(/event/action[@name="server_instance_name"]/value)[1]', N'VARCHAR(200)')
,Banco = d.value(N'(/event/action[@name="database_name"]/value)[1]', N'VARCHAR(200)')
,Comando = d.value(N'(/event/data[@name="statement"]/value)[1]', N'VARCHAR(max)')
,Comando_XML = d.query(N'(/event/data[@name="statement"]/value)[1]')
FROM (
SELECT CONVERT(XML, event_data) 
FROM sys.fn_xe_file_target_read_file(@Arquivo, NULL, NULL, NULL)
WHERE object_name IN (N'sql_statement_completed','rpc_completed')) AS x(d)
GO
/******************************* FIM SP *************************************/

-- Inicio da Captura de Eventos
EXEC spu_DBA_Query_Tuning_Start @Caminho = N'C:\_HandsOn_AdmSQL\_PerfMonitor', @Tempo = 0
EXEC spu_DBA_Query_Tuning_Start @Caminho = N'C:\_HandsOn_AdmSQL\_PerfMonitor', @Banco = N'AdventureWorks', @Tempo = 0


SELECT * FROM sys.server_event_sessions
WHERE startup_state = 1

-- Final da Captura de Eventos
EXEC spu_DBA_Query_Tuning_Stop @Caminho = N'C:\_HandsOn_AdmSQL\_PerfMonitor'

-- ALTER EVENT SESSION
ALTER EVENT SESSION DBA_Monitora_Consultas ON SERVER STATE = START
ALTER EVENT SESSION DBA_Monitora_Consultas ON SERVER STATE = STOP

SELECT * FROM DBA.dbo.DBA_Query_Tuning
GO