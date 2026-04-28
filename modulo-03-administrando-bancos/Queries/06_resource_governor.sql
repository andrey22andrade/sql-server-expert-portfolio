/***************************
		Resource Governor
****************************/

USE master
GO

/****************************************
 Verificando se RG está habilitado
*****************************************/
SELECT is_enabled FROM sys.resource_governor_configuration
-- 0 está dezabilitado
-- 1 está habilitado

/***********************************
 Criando Resource Pools
************************************/

-- Pool para OLTP
CREATE RESOURCE POOL Pool_OLTP
WITH (MAX_CPU_PERCENT = 70, MAX_MEMORY_PERCENT = 70)
GO

-- Pool para Relatórios
CREATE RESOURCE POOL Pool_Relatorio
WITH (MAX_CPU_PERCENT = 30, MAX_MEMORY_PERCENT = 30)
GO

/**********************************
 Criando Workload Groups
***********************************/
CREATE WORKLOAD GROUP Group_OLTP
USING Pool_OLTP
GO

CREATE WORKLOAD GROUP Group_Relatorio
USING Pool_Relatorio
GO

/***********************************
 Criando a Classifier Function
************************************/
CREATE OR ALTER FUNCTION dbo.Classifica_Workload()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN

DECLARE @Grupo sysname

IF APP_NAME() LIKE '%Relatorio%'
	SET @Grupo = 'Group_Relatorio'

ELSE IF APP_NAME() LIKE '%OLTP%'
	SET @Grupo = 'Group_OLTP'

ELSE
	SET @Grupo = 'default'

RETURN @Grupo

END
GO

/*******************************************************
 Associando a Classifier Function ao Resource Governor
********************************************************/
ALTER RESOURCE GOVERNOR
WITH (CLASSIFIER_FUNCTION = dbo.Classifica_Workload)
GO

/*********************************
 Aplicando o Resource Governor
**********************************/
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

SELECT is_enabled FROM sys.resource_governor_configuration
-- 1 foi habilitado

/*******************************************
 Abrir conexão 1 no SSMS com:
 - Application Name=OLTP
********************************************/
USE AdventureWorks
GO

SELECT * FROM Sales.SalesOrderDetail

/*******************************************
 Abrir conexão 2 no SSMS com:
 - Application Name=Relatorio
********************************************/
USE AdventureWorks
go

SELECT sod.ProductID, SUM(sod.LineTotal) AS TotalVendas
FROM Sales.SalesOrderDetail sod
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY sod.ProductID
ORDER BY TotalVendas DESC

/**********************************************
 Validando a classificação das sessões
***********************************************/
SELECT * FROM sys.dm_resource_governor_resource_pools
SELECT * FROM sys.dm_resource_governor_workload_groups

SELECT s.[session_id], s.login_name, s.[program_name],
wg.name AS WorkloadGroup, rp.name AS ResourcePool
FROM sys.dm_exec_sessions s
JOIN sys.dm_resource_governor_workload_groups wg ON s.group_id = wg.group_id
JOIN sys.dm_resource_governor_resource_pools rp ON wg.pool_id = rp.pool_id
WHERE s.is_user_process = 1

/*****************************************
 Monitorando consumo dos pools
******************************************/
SELECT [name], total_cpu_usage_ms, used_memory_kb
FROM sys.dm_resource_governor_resource_pools


/**********************************
 Remove configuração
***********************************/
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
GO

ALTER RESOURCE GOVERNOR RECONFIGURE
GO

DROP FUNCTION dbo.Classifica_Workload
GO

DROP WORKLOAD GROUP Group_OLTP
DROP WORKLOAD GROUP Group_Relatorio
GO

DROP RESOURCE POOL Pool_OLTP
DROP RESOURCE POOL Pool_Relatorio
GO

ALTER RESOURCE GOVERNOR DISABLE
GO