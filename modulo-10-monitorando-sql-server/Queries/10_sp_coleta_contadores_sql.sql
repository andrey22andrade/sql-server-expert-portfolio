USE DBA
GO

/*********************************
 Tabela DBA_Coleta_Contadores
*********************************/
DROP TABLE IF EXISTS dbo.DBA_Coleta_Contadores
GO

CREATE TABLE dbo.DBA_Coleta_Contadores (
DBA_Coleta_Contadores_ID INT NOT NULL IDENTITY CONSTRAINT pk_DBA_Coleta_Contadores PRIMARY KEY,
Empresa VARCHAR(100) NOT NULL,
NomeServidor VARCHAR(200) NOT NULL,
DataColeta DATETIME NOT NULL,

MEM_RAM_GB DECIMAL(16, 2) NULL,
MEM_Livre_GB DECIMAL(16, 2) NULL,

[Forwarded Records/sec] INT NULL,
[Full Scans/sec] INT NULL,
[Index Searches/sec] INT NULL,
[Page Splits/sec] INT NULL,
[Log Flush Waits/sec] INT NULL,
[Transactions/sec] INT NULL,
[Latch Waits/sec] INT NULL,
[Lock Waits/sec] INT NULL,
[Number of Deadlocks/sec] INT NULL,
[Batch Requests/sec] INT NULL,
[Page life expectancy] INT NULL,
[Total Server Memory (KB)] INT NULL,
[Target Server Memory (KB)] INT NULL,
[Database pages] INT NULL,
[Page lookups/sec] INT NULL,
[User Connections] INT NULL,
Processado BIT NOT NULL DEFAULT (0))
GO

/**************************************************
 Stored Procedure: spu_DBA_Coleta_Recorrente
 - Coleta de informações de desempenho
 - Agendar execução a cada 30 segundos

 SELECT * FROM dbo.DBA_Coleta_Contadores
 SELECT * FROM dbo.tb_DBA_Coleta_Waits

 TRUNCATE TABLE dbo.DBA_Coleta_Contadores
 TRUNCATE TABLE dbo.tb_DBA_Coleta_Waits
***************************************************/

-- DROP PROCEDURE spu_DBA_Coleta_Recorrente

CREATE OR ALTER PROC dbo.spu_DBA_Coleta_Recorrente
@Empresa VARCHAR(100) = 'SQL Server Expert'
AS
SET NOCOUNT ON

DECLARE @DataColeta DATETIME

/****************************************************************
 Valor Acumulado
 cntr_type = 272696576

 - aferir dois valores, subtrair e dividir pelo tempo em segundos
   (V2 - V1) / Intervalo Seg
*****************************************************************/

/****************************
 1a coleta
*****************************/

SELECT counter_name AS Contador,cntr_value AS Valor
INTO #PrimeiraColeta
FROM sys.dm_os_performance_counters
WHERE cntr_type = 272696576
AND instance_name IN ('_Total','')
AND counter_name IN ('Lock Waits/sec',
'Number of Deadlocks/sec',
'Transactions/sec',
'Log Flush Waits/sec','Latch Waits/sec',
'Full Scans/sec','Index Searches/sec',
'Forwarded Records/sec','Page Splits/sec',
'Batch Requests/sec','Page lookups/sec')
ORDER BY 1,2

WAITFOR DELAY '00:00:10'

/****************************
 2a Coleta
*****************************/

SELECT counter_name AS Contador,cntr_value AS Valor
INTO #SegundaColeta
FROM sys.dm_os_performance_counters
WHERE cntr_type = 272696576
AND instance_name IN ('_Total','')
AND counter_name IN ('Lock Waits/sec',
'Number of Deadlocks/sec',
'Transactions/sec',
'Log Flush Waits/sec','Latch Waits/sec',
'Full Scans/sec','Index Searches/sec',
'Forwarded Records/sec','Page Splits/sec',
'Batch Requests/sec','Page lookups/sec')
ORDER BY 1,2

SET @DataColeta = getdate()

/****************************
 CTE 1a coleta x 2a Coleta
*****************************/

;WITH CTE_DuasColetas AS (
SELECT @Empresa AS Empresa,@@SERVERNAME AS NomeServidor,
@DataColeta AS DataColeta,*
FROM (
SELECT a.Contador, (b.Valor - a.Valor) / 10 AS Valor
FROM #PrimeiraColeta a
JOIN #SegundaColeta b ON a.Contador = b.Contador) a
PIVOT (MAX(Valor) FOR Contador IN 
([Forwarded Records/sec],[Full Scans/sec],[Index Searches/sec],
[Page Splits/sec],[Log Flush Waits/sec],[Transactions/sec],
[Latch Waits/sec],[Lock Waits/sec],[Number of Deadlocks/sec],
[Batch Requests/sec],[Page lookups/sec]) ) b),

/***********************
 CTE Valor direto
************************/

CTE_UmaColeta AS (
SELECT @Empresa AS Empresa,@@SERVERNAME AS NomeServidor,
@DataColeta AS DataColeta,
(SELECT 
CAST((total_physical_memory_kb/1024.00)/1024.00 AS DECIMAL(16,2)) AS MEM_RAM_GB
FROM sys.dm_os_sys_memory) AS MEM_RAM_GB,
(SELECT 
CAST((available_physical_memory_kb/1024.00)/1024.00 AS DECIMAL(16,2)) AS MEM_Livre_GB
FROM sys.dm_os_sys_memory) AS MEM_Livre_GB,* 

FROM (
SELECT counter_name,cntr_value
FROM sys.dm_os_performance_counters
WHERE cntr_type = 65792
AND instance_name IN ('_Total','')
AND counter_name IN ('Page life expectancy',
'Total Server Memory (KB)','Target Server Memory (KB)',
'Database pages','User Connections')) a
PIVOT (MAX(cntr_value) FOR counter_name IN 
([Page life expectancy],[Total Server Memory (KB)],[Target Server Memory (KB)],
[Database pages],[User Connections]) ) b)

/*****************************
 Inclusão dados de contadores
******************************/
INSERT dbo.DBA_Coleta_Contadores
(Empresa, NomeServidor, DataColeta, MEM_RAM_GB, MEM_Livre_GB, 
[Forwarded Records/sec], [Full Scans/sec], [Index Searches/sec], [Page Splits/sec], 
[Log Flush Waits/sec], [Transactions/sec], [Latch Waits/sec], [Lock Waits/sec], 
[Number of Deadlocks/sec], [Batch Requests/sec], [Page life expectancy], 
[Total Server Memory (KB)], [Target Server Memory (KB)], [Database pages], [User Connections],
[Page lookups/sec])

SELECT a.Empresa,a.NomeServidor,a.DataColeta, a.MEM_RAM_GB, a.MEM_Livre_GB,
[Forwarded Records/sec], [Full Scans/sec], [Index Searches/sec], [Page Splits/sec], 
[Log Flush Waits/sec], [Transactions/sec], [Latch Waits/sec], [Lock Waits/sec], 
[Number of Deadlocks/sec], [Batch Requests/sec], [Page life expectancy], 
[Total Server Memory (KB)], [Target Server Memory (KB)], [Database pages],[User Connections],
[Page lookups/sec]
FROM CTE_UmaColeta a 
JOIN CTE_DuasColetas b ON b.Empresa = a.Empresa 
AND b.NomeServidor = a.NomeServidor AND b.DataColeta = a.DataColeta

DROP TABLE #PrimeiraColeta
DROP TABLE #SegundaColeta
GO

/******************************************** FIM SP ******************************************/

/***************************************
 Criar JOB executando a cada 5 minutos
****************************************/

EXEC dbo.spu_DBA_Coleta_Recorrente @Empresa = 'SQL Server Expert'

SELECT * FROM dbo.DBA_Coleta_Contadores

/**********************************************************
 Consulta de Análise consolidando os valores por Hora
***********************************************************/
GO
DECLARE @DataAnalise DATE = '20240701'

SELECT CAST(DataColeta AS DATE) AS Dia, 
CONVERT(CHAR(2),DataColeta,108) AS Hora,

AVG(MEM_RAM_GB) AS MEM_RAM_GB,
AVG(MEM_Livre_GB) AS MEM_Livre_GB,

AVG([User Connections]) AS UserConnections_AVG,
MAX([User Connections]) AS UserConnections_MAX,

AVG([Batch Requests/sec]) AS BatchRequests_AVG,
MAX([Batch Requests/sec]) AS BatchRequests_MAX,

AVG([Transactions/sec]) AS Transactions_AVG,
MAX([Transactions/sec]) AS Transactions_MAX,

(MAX([Total Server Memory (KB)])/1024)/1024 AS TotalServerMemory_GB_MAX,
(MAX([Target Server Memory (KB)])/1024)/1024 AS TargetServerMemory_GB_MAX,
AVG(((CAST([Database pages] AS DECIMAL(16,2)) * 8.00)/1024)/1024) AS BufferPool_GB,

-- Ideal 20 Page Splits a cada 100 Batch Requests no maximo
AVG([Page Splits/sec]) AS PageSplits_AVG,
AVG(([Batch Requests/sec] / 100)) * 20 AS PageSplits_Ideal,

-- Ideal 10 Forwarded Records a cada 100 Batch Requests no máximo
AVG([Forwarded Records/sec]) AS ForwardedRecords_AVG,
AVG(([Batch Requests/sec] / 100)) * 10 AS ForwardedRecords_Ideal,

-- (Index Searches/sec) / (Full Scans/sec) deve ser superior a 500
AVG([Full Scans/sec]) AS FullScans_AVG, 
AVG([Index Searches/sec]) AS IndexSearches_AVG, 
AVG([Index Searches/sec]) / CASE WHEN AVG([Full Scans/sec]) = 0 THEN 1 ELSE AVG([Full Scans/sec]) END AS ProporcaoSearcheScan_AVG, -- Verificar
MAX([Index Searches/sec]) / CASE WHEN MAX([Full Scans/sec]) = 0 THEN 1 ELSE MAX([Full Scans/sec]) END AS ProporcaoSearcheScan_MAX, -- Verificar
AVG([Index Searches/sec] / CASE WHEN [Full Scans/sec] = 0 THEN 1 ELSE [Full Scans/sec] END) AS ProporcaoSearcheScan_AVG2, -- Verificar
MAX([Index Searches/sec] / CASE WHEN [Full Scans/sec] = 0 THEN 1 ELSE [Full Scans/sec] END) AS ProporcaoSearcheScan_MAX2, -- Verificar
500.00 AS ProporcaoSearcheScan_Ideal,

-- (Page lookups) / (Batch Requests) deve ser menor que 100 (plano de execução ineficiente, consultas com volume alto de IO)
AVG([Page lookups/sec]) / CASE WHEN AVG([Batch Requests/sec]) = 0 THEN 1 ELSE AVG([Batch Requests/sec]) END AS Pagelookups_AVG,
100.00 AS Pagelookups_Ideal,

--  Page life expectancy deve ser superior a (Total Server Memory em GB) / 4 * 300
AVG([Page life expectancy]) AS PageLifeExpectancy_AVG,
AVG(((([Total Server Memory (KB)]/1024)/1024) / 4)) * 300 AS PageLifeExpectancy_Ideal,

AVG([Log Flush Waits/sec]) AS LogFlushWaits_AVG,

-- Vaor ideal inferior a 1.00
AVG([Lock Waits/sec]) AS LockWaitsSec_AVG,
MAX([Lock Waits/sec]) AS LockWaitsSec_MAX,
1.00 AS LockWaitsSec_Ideal,

MAX([Number of Deadlocks/sec]) AS Deadlocks_sec

FROM dbo.DBA_Coleta_Contadores
WHERE DataColeta >= @DataAnalise AND DataColeta < DATEADD(dd,1,@DataAnalise)
GROUP BY CAST(DataColeta AS DATE), CONVERT(CHAR(2),DataColeta,108)
GO