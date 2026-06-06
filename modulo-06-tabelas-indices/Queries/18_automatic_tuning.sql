/******************
 - Automatic Tuning
*******************/

USE master
GO

/**************************
 Prepara HandsOn
***************************/
CREATE DATABASE HandsOn
GO

ALTER DATABASE HandsOn SET RECOVERY simple
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SENSITIVE_PLAN_OPTIMIZATION = OFF
-- ou
ALTER DATABASE HandsOn SET COMPATIBILITY_LEVEL = 150 -- SQL Server 2019
GO

use HandsOn
GO

DROP TABLE IF EXISTS dbo.SalesOrderHeader
GO

CREATE TABLE dbo.SalesOrderHeader (
SalesOrderID INT IDENTITY NOT NULL CONSTRAINT pk_SalesOrderHeader PRIMARY KEY,
RevisionNumber TINYINT NOT NULL,
OrderDate DATETIME NOT NULL,
DueDate DATETIME NOT NULL,
ShipDate DATETIME NULL,
Status TINYINT NOT NULL,
OnlineOrderFlag BIT NOT NULL,
SalesOrderNumber NVARCHAR(25) NOT NULL,
PurchaseOrderNumber NVARCHAR(25) NULL,
AccountNumber NVARCHAR(15) NULL,
CustomerID INT NOT NULL,
SalesPersonID INT NULL,
SubTotal MONEY NOT NULL,
TaxAmt MONEY NOT NULL,
Freight MONEY NOT NULL,
TotalDue MONEY NOT NULL,
Comment NVARCHAR(128) NULL,
rowguid UNIQUEIDENTIFIER NOT NULL,
ModifiedDate DATETIME NOT NULL)
GO

INSERT dbo.SalesOrderHeader
(RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, SubTotal, TaxAmt, Freight, TotalDue, Comment, rowguid, ModifiedDate)
SELECT RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, h.AccountNumber, h.CustomerID, 
SalesPersonID, SubTotal, TaxAmt, Freight, TotalDue, Comment, h.rowguid, h.ModifiedDate
FROM AdventureWorks.Sales.SalesOrderHeader h
GO

INSERT dbo.SalesOrderHeader
(RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, SubTotal, TaxAmt, Freight, TotalDue, Comment, rowguid, ModifiedDate)
SELECT RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, h.AccountNumber, h.CustomerID, 
SalesPersonID, SubTotal, TaxAmt, Freight, TotalDue, Comment, h.rowguid, h.ModifiedDate
FROM AdventureWorks.Sales.SalesOrderHeader h
WHERE RevisionNumber = 8
GO 6

CREATE INDEX ix_SalesOrderHeader_RevisionNumber ON dbo.SalesOrderHeader (RevisionNumber)
GO

/************************ FIM Prepara HandsOn **********************/

SELECT COUNT(*) FROM dbo.SalesOrderHeader -- 220.075 linhas

SELECT RevisionNumber,COUNT(*) AS Qtdlinhas
FROM dbo.SalesOrderHeader
GROUP BY RevisionNumber
ORDER BY 2 DESC
GO

/*
RevisionNumber	Qtdlinhas
8				220045
9				30
*/


/*******************
 Cria SPs
********************/

CREATE or ALTER PROCEDURE dbo.spu_OrdersAVG
@RevisionNumber TINYINT
AS
SET NOCOUNT ON

SELECT AVG(SubTotal + Freight + TaxAmt) AS Media
FROM dbo.SalesOrderHeader
WHERE RevisionNumber = @RevisionNumber
GO

CREATE OR ALTER PROCEDURE dbo.spu_Regression
AS
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE

DECLARE @Param_RevisionNumber TINYINT = 9
EXEC dbo.spu_OrdersAVG @RevisionNumber = @Param_RevisionNumber
GO

/************** FIM SPs *******************/

/****************************************
 Mostrar Planos de Execução
*****************************************/
SET STATISTICS IO ON

SET STATISTICS IO OFF

SELECT AVG(SubTotal + Freight + TaxAmt) AS Media
FROM dbo.SalesOrderHeader
WHERE RevisionNumber = 8
GO

/*
Clustered Index Scan
Table 'SalesOrderHeader'. Scan count 1, logical reads 4412
*/

SELECT AVG(SubTotal + Freight + TaxAmt) AS Media
FROM dbo.SalesOrderHeader
WHERE RevisionNumber = 9
GO

/*
Index Seek + Lookup
Table 'SalesOrderHeader'. Scan count 1, logical reads 104
*/

USE master
GO

ALTER DATABASE HandsOn 
SET QUERY_STORE = ON 
(
OPERATION_MODE = READ_WRITE, ------------------------- Habilita captura de queries
CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), -- Mantém histórico de 30 dias
DATA_FLUSH_INTERVAL_SECONDS = 60, -------------------- Flush para disco a cada 1 minuto
MAX_STORAGE_SIZE_MB = 2048, --------------------------- Limite de tamanho em MB
INTERVAL_LENGTH_MINUTES = 1, ------------------------- Agregação dos dados por 1 min
SIZE_BASED_CLEANUP_MODE = AUTO, ---------------------- Limpeza automática se atingir o limite
QUERY_CAPTURE_MODE = ALL, ---------------------------- Captura todas as queries
MAX_PLANS_PER_QUERY = 200 ---------------------------- Limite de planos diferentes por query
)
GO

USE HandsOn
GO

ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE
ALTER DATABASE current SET QUERY_STORE CLEAR ALL

/*********************************************
 Executar no SQL Query Stress 100000x 4 Threads
 Monitorar PerfMonitor: 
 - Objeto: SQLServer:SQL Statistics
 - Contador: Batch Requests/sec 
**********************************************/
DECLARE @p_RevisionNumber TINYINT = 8
EXEC dbo.spu_OrdersAVG @RevisionNumber = @p_RevisionNumber

/*********************************
 Executar 1x no SQL Query Stress
**********************************/
EXEC dbo.spu_Regression

/***************************************************
 Recomendações para Regressão de plano de Execução
****************************************************/
SELECT * FROM sys.dm_db_tuning_recommendations

SELECT Reason, Score,
JSON_VALUE(state, '$.currentValue') AS [Status],
JSON_VALUE(state, '$.reason') AS Status_Reason,
JSON_VALUE(details, '$.implementationDetails.script') script,
d.*
FROM sys.dm_db_tuning_recommendations
CROSS APPLY OPENJSON (Details, '$.planForceDetails')
WITH (  
[query_id] INT '$.queryId',
[new plan_id] INT '$.regressedPlanId',
[forcedPlanId] INT '$.forcedPlanId'
) AS d
/*
======================================================================
Status		Descrição
----------------------------------------------------------------------
Active		A recomendação foi detectada, mas ainda não aplicada. 
            O DBA pode pegar o script sugerido e aplicar manualmente.
----------------------------------------------------------------------
Verifying	Aplicou a recomendação e está em fase de verificação, 
            comparando o desempenho dos planos.
----------------------------------------------------------------------
Success		A recomendação foi aplicada com sucesso e comprovou 
            melhoria de desempenho.
----------------------------------------------------------------------
Reverted	A recomendação chegou a ser aplicada, mas foi revertida 
            porque não trouxe ganho significativo.
----------------------------------------------------------------------
Expired		A recomendação expirou e não pode mais ser aplicada.
======================================================================


========================================================================================================
Status Reason		                Descrição
--------------------------------------------------------------------------------------------------------
SchemaChanged	                    A recomendação expirou porque o esquema de uma tabela referenciada 
                                    foi alterado.
--------------------------------------------------------------------------------------------------------
StatisticsChanged                   A recomendação expirou devido à atualização de estatísticas em uma 
                                    tabela usada pela query.
--------------------------------------------------------------------------------------------------------
ForcingFailed	                    O plano recomendado não pôde ser forçado. Consulte 
                                    sys.query_store_plan.last_force_failure_reason_desc 
                                    para entender o motivo.
--------------------------------------------------------------------------------------------------------
AutomaticTuningOptionDisabled	    O FORCE_LAST_GOOD_PLAN foi desabilitado pelo usuário durante a 
                                    verificação. Reative com ALTER DATABASE SET AUTOMATIC_TUNING.
--------------------------------------------------------------------------------------------------------
UnsupportedStatementType            O plano não pode ser forçado porque o tipo de instrução não é 
                                    suportado (ex.: cursores, INSERT BULK).
--------------------------------------------------------------------------------------------------------
LastGoodPlanForced	                O plano anterior (“last good plan”) foi forçado com sucesso.
--------------------------------------------------------------------------------------------------------
AutomaticTuningOptionNotEnabled	    O Automatic Tuning não está habilitado no banco de dados.
--------------------------------------------------------------------------------------------------------
VerificationAborted	                O processo de verificação foi interrompido (reinício do SQL Server 
                                    ou limpeza do Query Store).
--------------------------------------------------------------------------------------------------------
VerificationForcedQueryRecompile	A verificação mostrou nenhuma melhora significativa, forçando 
                                    recompilação da query.
--------------------------------------------------------------------------------------------------------
PlanForcedByUser	                O plano foi forçado manualmente pelo DBA com 
                                    sp_query_store_force_plan.
--------------------------------------------------------------------------------------------------------
PlanUnforcedByUser	                O plano forçado foi removido manualmente 
                                    (sp_query_store_unforce_plan).
========================================================================================================


*/
/*************************************
 Planos de Execução Forçados
**************************************/

SELECT qsq.query_id, qsp.plan_id, qsp.is_forced_plan, qsp.force_failure_count,
qsp.last_force_failure_reason_desc, rs.count_executions, rs.avg_duration, rs.last_execution_time
FROM sys.query_store_query qsq
JOIN sys.query_store_plan qsp ON qsp.query_id = qsq.query_id
JOIN sys.query_store_runtime_stats rs ON rs.plan_id = qsp.plan_id
WHERE qsp.is_forced_plan = 1
ORDER BY rs.last_execution_time DESC

-- Forçando Plano de Execução manualmente
EXEC sp_query_store_force_plan @query_id = 1, @plan_id = 1
EXEC sp_query_store_unforce_plan @query_id = 1, @plan_id = 1


/*******************************
 Habilitando AUTOMATIC_TUNING
********************************/

ALTER DATABASE current SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = ON)

SELECT name, desired_state_desc, actual_state_desc, reason_desc
FROM sys.database_automatic_tuning_options
GO