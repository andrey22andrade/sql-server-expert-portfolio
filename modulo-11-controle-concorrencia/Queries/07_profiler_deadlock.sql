/*******************************************************************
 Hands On: Stored Procedure para monitorar Deadlock com SQL Profiler
********************************************************************/

USE master
GO

/***********************************************************
 Cria Stored Procedure na master para ativar trace
************************************************************/

CREATE OR ALTER PROC dbo.spu_CriaTrace_Deadlock
@Caminho VARCHAR(128), -- local de escrita do arquivo, finalizar com \
@TamArq BIGINT = 100 -- valor em MB, tamanho do arquivo para criar outro
AS
DECLARE @IDtrace INT, @PathFile NVARCHAR(128), @Retorno INT
DECLARE @Data NVARCHAR(128)
SET @Data = CONVERT(NVARCHAR(30),GETDATE(),112)

SET @PathFile = @Caminho + N'Trace_' + @@SERVERNAME + ' ' + @Data;

-- Cria trace
EXEC @Retorno = sp_trace_create @traceid = @IDtrace OUTPUT, @options = 2, @tracefile = @PathFile, @maxfilesize = @TamArq, @stoptime = null;

IF @Retorno <> 0 BEGIN
   PRINT 'Erro Criando Trace: ' + STR(@Retorno)
   RETURN
END
PRINT 'ID Trace: ' + STR(@IDtrace);

/* Retorno:
0 No error. 
1 Unknown error. 
10 Invalid options. Returned when options specified are incompatible. 
12 File not created. 
13 Out of memory. Returned when there is not enough memory to perform the specified action. 
14 Invalid stop time. Returned when the stop time specified has already happened. 
15 Invalid parameters. Returned when the user supplied incompatible parameters. 
*/

-- Cria Evento
DECLARE @bit bit
SET @bit = 1
-- Lock:Deadlock graph
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid =  1, @on = @bit -- TextData
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid = 41, @on = @bit -- LoginSid
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid =  4, @on = @bit -- TransactionID	
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid = 12, @on = @bit -- SPID
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid = 11, @on = @bit -- LoginName
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid = 14, @on = @bit -- StartTime
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid = 26, @on = @bit -- ServerName
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid = 51, @on = @bit -- EventSequence
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid = 60, @on = @bit -- IsSystem
exec sp_trace_setevent @traceid = @IDtrace, @eventid = 148, @columnid = 64, @on = @bit -- SessionLoginName


exec sp_trace_setstatus @traceid = @IDtrace, @status = 1 
-- exec sp_trace_setstatus @traceid = 1, @status = 2 

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
/*********************** FIM SP ****************************/


-- Ativa trace executando a SP (retorna o ID do trace)
exec dbo.spu_CriaTrace_Deadlock @Caminho = 'C:\_HandsOn_AdmSQL\_DBA_Monitora\'


-- Informações do Trace
SELECT * FROM sys.traces

DECLARE @TraceID INT = 2
SELECT ei.eventid EventID,e.name EventName,c.trace_column_id ColumnID,c.name ColumnName
FROM fn_trace_geteventinfo(@TraceID) ei JOIN sys.trace_events e ON ei.eventid = e.trace_event_id
JOIN sys.trace_columns c ON ei.columnid = c.trace_column_id
GO

/* @status
0 Stops the specified trace. 
1 Starts the specified trace. 
2 Closes the specified trace and deletes its definition from the server. 
*/
GO
DECLARE @ID INT
SELECT @ID = id FROM sys.traces where path like 'C:\_HandsOn_AdmSQL\_DBA_Monitora\%'
exec sp_trace_setstatus @traceid = @ID, @status = 0 
exec sp_trace_setstatus @traceid = @ID, @status = 2 
GO


/***********************
 Exclui SP
************************/
DROP PROC dbo.spu_CriaTrace_Deadlock
GO