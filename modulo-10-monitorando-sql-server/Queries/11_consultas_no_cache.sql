/****************************
 Hands On: Consultas no Cache
*****************************/
USE master
GO

/*********************
 Consultas no Cache
**********************/ 
SELECT --top(10) 
st.[text] AS Consulta, 
execution_count AS QtdExec, 
last_elapsed_time  AS Tempo_UltimaExec,
last_logical_reads AS LeituraIO_UltimaExec, 
last_logical_writes AS EscritaIO_UltimaExec,
last_worker_time AS CPU_UltimaExec
FROM sys .dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
WHERE st.[text] IS NOT NULL 
AND st.[text] NOT LIKE 'FETCH%' 
AND st.[text] NOT LIKE '%CREATE%'
ORDER BY execution_count DESC


/********************************************
 Consultas no Cache com Plano de Execução
*********************************************/
SELECT --top(10) 
st.[text] AS Consulta, 
execution_count AS QtdExec, 
last_elapsed_time  AS Tempo_UltimaExec,
last_logical_reads AS LeituraIO_UltimaExec, 
last_logical_writes AS EscritaIO_UltimaExec,
last_worker_time AS CPU_UltimaExec,
pl.query_plan AS Plano_Exec 
FROM sys.dm_exec_query_stats qs  
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st 
OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) pl 
WHERE st.[text] IS NOT NULL 
AND st.[text] NOT LIKE 'FETCH%' 
AND st.[text] NOT LIKE '%CREATE%'
ORDER BY execution_count DESC

/*************************************
 Consultas no Cache Missing Index
**************************************/

USE AdventureWorks_SemIndice
GO
-- Consulta 1
SELECT d.SalesOrderID, d.OrderQty, h.OrderDate, o.[Description], o.StartDate, o.EndDate
FROM Sales.SalesOrderDetail d
INNER JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
INNER JOIN Sales.SpecialOffer o ON d.SpecialOfferID = o.SpecialOfferID
WHERE d.SpecialOfferID <> 1

-- Consulta 2
SELECT h.SalesOrderID, h.OrderDate, h.SubTotal, p.SalesQuota
FROM Sales.SalesPerson p
INNER JOIN Sales.SalesOrderHeader h 
ON p.BusinessEntityID = h.SalesPersonID


--Color = 'Back' AND Size = 44

SELECT --top(10) 
st.[text] AS Consulta, 
execution_count AS QtdExec, 
last_elapsed_time  AS Tempo_UltimaExec,
last_logical_reads AS LeituraIO_UltimaExec, 
last_logical_writes AS EscritaIO_UltimaExec,
last_worker_time AS CPU_UltimaExec,
pl.query_plan AS Plano_Exec
FROM sys.dm_exec_query_stats qs  
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st 
OUTER APPLY sys.dm_exec_query_plan(qs.plan_handle) pl 
WHERE st.[text] IS NOT NULL 
AND st.[text] NOT LIKE 'FETCH%' 
AND st.[text] NOT LIKE '%CREATE%'
AND pl.query_plan.exist (N'declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/showplan";
/ShowPlanXML/BatchSequence/Batch/Statements/StmtSimple/QueryPlan//MissingIndexes') = 1
ORDER BY execution_count DESC
GO