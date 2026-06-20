/***********************
 Hands On: Default Trace
************************/

USE master
GO

-- Acessar dados do Default Trace
SELECT * FROM fn_trace_gettable  
('C:\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Log\log.trc', DEFAULT)
GO

-- Desabilitar Default Trace
EXEC SP_CONFIGURE 'default trace enabled',0
RECONFIGURE
GO