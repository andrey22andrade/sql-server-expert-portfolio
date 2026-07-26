/****************************************
 Hands On: sys.dm_os_performance_counters
 https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-os-performance-counters-transact-sql?view=sql-server-ver16
*****************************************/

SELECT * FROM sys.dm_os_performance_counters

SELECT DISTINCT cntr_type  FROM sys.dm_os_performance_counters

SELECT * FROM sys.dm_os_performance_counters
WHERE counter_name  IN ('Buffer cache hit ratio base','Buffer cache hit ratio')

/****************************************************
 Ultimo valor observado
 cntr_type = 65792
*****************************************************/
SELECT object_name,counter_name,instance_name,cntr_value
FROM sys.dm_os_performance_counters
WHERE cntr_type = 65792 -- last observed value directly
AND instance_name IN ('_Total','')
AND counter_name IN ('Page life expectancy',
'Total Server Memory (KB)','Target Server Memory (KB)')
ORDER BY 1,2

/****************************************************************
 Valor Acumulado
 cntr_type = 272696576

 - aferir dois valores, subtrair e dividir pelo tempo em segundos
   (V2 - V1) / Intervalo Seg
*****************************************************************/
SELECT object_name,counter_name,instance_name,cntr_value
FROM sys.dm_os_performance_counters
WHERE cntr_type = 272696576
AND instance_name IN ('_Total','')
AND counter_name IN ('Lock Waits/sec',
'Number of Deadlocks/sec','Transactions/sec',
'Log Flush Waits/sec','Latch Waits/sec',
'Full Scans/sec','Index Searches/sec',
'Forwarded Records/sec','Page Splits/sec',
'Batch Requests/sec')
ORDER BY 1,2

/****************************************************************
 Valor Acumulado
 cntr_type = 1073874176 (PERF_AVERAGE_BULK)
 cntr_type = 1073939712 (PERF_LARGE_RAW_BASE)

 - Aferir dois valores onde:
   A = PERF_AVERAGE_BULK
   B = PERF_LARGE_RAW_BASE 
   (A2 – A1) / (B2 – B1)
*****************************************************************/
SELECT object_name,counter_name,instance_name,cntr_value
FROM sys.dm_os_performance_counters
WHERE cntr_type IN (1073874176,1073939712)
AND instance_name IN ('_Total','')
AND object_name = 'SQLServer:Locks'
ORDER BY 1,2

/****************************************************************
 Valor Acumulado
 cntr_type = 1073939712 (PERF_LARGE_RAW_FRACTION)
 cntr_type = 537003264 (PERF_LARGE_RAW_BASE)

 - Aferir dois valores onde:
   A = PERF_LARGE_RAW_FRACTION
   B = PERF_LARGE_RAW_BASE 
   100 * (B / A)
*****************************************************************/
SELECT object_name,counter_name,instance_name,cntr_value
FROM sys.dm_os_performance_counters
WHERE cntr_type IN (1073939712,537003264)
AND instance_name IN ('_Total','')
AND object_name = 'SQLServer:Buffer Manager'
ORDER BY 1,2



-- Informações SQL e Windows
SELECT 
RIGHT(@@version, LEN(@@version)- 3 -CHARINDEX (' ON ', @@VERSION)) AS Windows_Edicao, 
SERVERPROPERTY('Edition') AS SQL_Edicao,
SERVERPROPERTY('ProductVersion') AS SQL_Build,  
SERVERPROPERTY('ProductLevel') AS SQL_ServicePack, 
CASE WHEN SERVERPROPERTY('IsIntegratedSecurityOnly') = 1 THEN 'Windows' ELSE 'Misto' END AS SQL_Autenticacao,
CASE WHEN SERVERPROPERTY('IsHadrEnabled') = 1 THEN 'Sim' ELSE 'Não' END AS SQL_AlwaysOn,
CASE WHEN SERVERPROPERTY('IsClustered') = 1 THEN 'Sim' ELSE 'Não' END AS SQL_Cluster,
SERVERPROPERTY('Collation') AS SQL_Collation

-- Informações Memória
SELECT 
CAST((total_physical_memory_kb/1024.00)/1024.00 AS DECIMAL(16,2)) AS MEM_RAM_GB,
CAST((available_physical_memory_kb/1024.00)/1024.00 AS DECIMAL(16,2)) AS MEM_Livre_GB
FROM sys.dm_os_sys_memory