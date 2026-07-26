/******************************************************************
 Autor: Landry Duailibe

 Stored Procedure para monitorar consultas com SQL Server Profiler
*******************************************************************/

USE master
GO

/***********************************************************
 Cria Stored Procedure na master para ativar trace em banco
************************************************************/
-- DROP PROC spu_CriaTrace
CREATE OR ALTER PROC dbo.spu_CriaTrace
@Banco VARCHAR(1000), -- Nome do Banco de dados para capturar AS consultas
@Caminho NVARCHAR(128), -- local de escrita do arquivo
@FiltroTempo BIGINT = 120000, -- valor em Milissegundo (ms), captura consultas acima deste tempo
@TamArq BIGINT = 100 -- valor em MB, tamanho do arquivo para criar outro
AS
DECLARE @IDtrace INT, @PathFile NVARCHAR(128), @Retorno INT, @FiltroBanco INT;
DECLARE @Data NVARCHAR(128)
SET @Data = convert(NVARCHAR(30),getdate(),112)

SET @PathFile = @Caminho + N'\Trace_' + @@SERVERNAME + ' ' + @Data;
SET @FiltroBanco = db_id(@Banco)

-- Cria trace
EXEC @Retorno = sp_trace_create @traceid = @IDtrace OUTPUT, @options = 2, @tracefile = @PathFile, @maxfilesize = @TamArq, @stoptime = null;

IF @Retorno <> 0 BEGIN
   PRINT 'Erro Criando Trace: ' + str(@Retorno)
   RETURN
END
PRINT 'ID Trace: ' + str(@IDtrace);

/* Retorno:
0 No error. 
1 Unknown error. 
10 Invalid options. Returned when options specified are incompatible. 
12 File not created. 
13 Out of memory. Returned when there is not enough memory to perform the specified action. 
14 Invalid stop time. Returned when the stop time specified has already happened. 
15 Invalid parameters. Returned when the user supplied incompatible parameters. 
*/

/*********************************************** 
 Cria Eventos
 https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-trace-setevent-transact-sql?view=sql-server-ver16

 - 1 Minuto = 60 Segundos = 60.000 Milissegundos = 60.000.000 Microsegundos
 - Duração em Milissegundo (ms)
 - CPU em Milissegundo (ms)
***********************************************/
DECLARE @bit bit
SET @bit = 1
-- RPC:Completed
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid =  1, @on = @bit -- TextData
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid = 10, @on = @bit -- ApplicationName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid = 11, @on = @bit -- SQLSecurityLoginName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid = 12, @on = @bit -- SPID
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid = 13, @on = @bit -- Duration
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid = 16, @on = @bit -- Reads
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid = 17, @on = @bit -- Writes
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid = 18, @on = @bit -- CPU
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid =  3, @on = @bit -- DatabaseID
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid = 35, @on = @bit -- DatabaseName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 10, @columnid = 15, @on = @bit -- END Time
-- SQL:BatchCompleted
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid =  1, @on = @bit -- TextData
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid = 10, @on = @bit -- ApplicationName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid = 11, @on = @bit -- SQLSecurityLoginName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid = 12, @on = @bit -- SPID
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid = 13, @on = @bit -- Duration
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid = 16, @on = @bit -- Reads
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid = 17, @on = @bit -- Writes
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid = 18, @on = @bit -- CPU
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid =  3, @on = @bit -- DatabaseID
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid = 35, @on = @bit -- DatabaseName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 12, @columnid = 15, @on = @bit -- END Time
-- SQL:StmtCompleted
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid =  1, @on = @bit -- TextData
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid = 10, @on = @bit -- ApplicationName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid = 11, @on = @bit -- SQLSecurityLoginName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid = 12, @on = @bit -- SPID
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid = 13, @on = @bit -- Duration
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid = 16, @on = @bit -- Reads
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid = 17, @on = @bit -- Writes
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid = 18, @on = @bit -- CPU
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid =  3, @on = @bit -- DatabaseID
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid = 35, @on = @bit -- DatabaseName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 41, @columnid = 15, @on = @bit -- END Time
-- SP:Completed
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid =  1, @on = @bit -- TextData
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid = 10, @on = @bit -- ApplicationName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid = 11, @on = @bit -- SQLSecurityLoginName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid = 12, @on = @bit -- SPID
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid = 13, @on = @bit -- Duration
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid = 16, @on = @bit -- Reads
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid = 17, @on = @bit -- Writes
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid = 18, @on = @bit -- CPU
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid =  3, @on = @bit -- DatabaseID
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid = 35, @on = @bit -- DatabaseName
EXEC sp_trace_setevent @traceid = @IDtrace, @eventid = 43, @columnid = 15, @on = @bit -- END Time

-- ****************** Cria FILTRO
-- Filtro do banco
EXEC sp_trace_setfilter @traceid = @IDtrace, @columnid = 3,@logical_operator = 0,@comparison_operator = 0,@value = @FiltroBanco

-- Filtro no tempo de duração
EXEC sp_trace_setfilter @traceid = @IDtrace, @columnid = 13,@logical_operator = 0,@comparison_operator = 4,@value = @FiltroTempo

-- Filtro em Object_id > 100
EXEC sp_trace_setfilter @traceid = @IDtrace, @columnid = 22,@logical_operator = 0,@comparison_operator = 2,@value = 100

/*
@logical_operator -> AND (0) OR OR (1)

@comparison_operator :
0 = (Equal) 
1 <> (Not Equal) 
2 > (Greater Than) 
3 < (Less Than) 
4 >= (Greater Than OR Equal) 
5 <= (Less Than OR Equal) 
6 LIKE  
7 NOT LIKE  
*/

EXEC sp_trace_setstatus @traceid = @IDtrace, @status = 1 
-- EXEC sp_trace_setstatus @traceid = 1, @status = 2 

/* @status
0 Stops the specified trace. 
1 Starts the specified trace. 
2 Closes the specified trace and deletes its definition from the server. 
*/

/* Retorno:
0 No error. 
1 Unknown error. 
8 The specified Status is not valid. 
9 The specified Trace Handle is not valid. 
13 Out of memory. Returned when there is not enough memory to perform the specified action. 
*/
GO
/****************************************** FIM SP *******************************************/


-- Ativa trace executando a SP (retorna o ID do trace)
EXEC spu_CriaTrace @Banco='AdventureWorks',@Caminho=N'C:\_HandsOn_AdmSQL\_PerfMonitor',@FiltroTempo=0

-- Informações do Trace
SELECT * FROM sys.traces

SELECT ei.eventid EventID,e.name EventName,c.trace_column_id ColumnID,c.name ColumnName
FROM fn_trace_geteventinfo(1) ei JOIN sys.trace_events e ON ei.eventid = e.trace_event_id
JOIN sys.trace_columns c ON ei.columnid = c.trace_column_id

/* @status
0 Stops the specified trace. 
1 Starts the specified trace. 
2 Closes the specified trace and deletes its definition from the server. 
*/

GO
DECLARE @ID INT
SELECT @ID = id FROM sys.traces WHERE PATH LIKE 'C:\_HandsOn_AdmSQL\_PerfMonitor%'
EXEC sp_trace_setstatus @traceid = @ID, @status = 0 -- Stop
EXEC sp_trace_setstatus @traceid = @ID, @status = 2 -- Close
GO

-- Importar Resultado para tabela
DROP TABLE IF EXISTS aula.dbo.tmp_Trace
GO

SELECT * 
INTO aula.dbo.tmp_Trace 
FROM fn_trace_gettable('C:\_HandsOn_AdmSQL\_PerfMonitor\Trace_SRVSQL2022 20240304.trc', DEFAULT)

SELECT * FROM aula.dbo.tmp_Trace ORDER BY duration DESC

-- AS 10 consultas com maior tempo de execução
SELECT TOP 10 
TextData, EndTime, Duration, Reads, Writes, CPU, 
DatabaseName, ApplicationName, HostName
FROM aula.dbo.tmp_Trace 
ORDER BY duration DESC

-- Comando T-SQL em XML
SELECT ApplicationName, LoginName,Duration/1000000 AS Duracao_Seg,TextData,
CAST('<A><![CDATA[' + CAST(TextData AS NVARCHAR(MAX)) + ']]></A>' AS XML) AS Comando
FROM aula.dbo.tmp_Trace
ORDER BY cast(TextData AS VARCHAR(MAX)), Duration DESC
GO