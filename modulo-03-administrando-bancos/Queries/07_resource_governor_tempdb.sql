/*********************************************
 – Resource Governor TempDB no SQL Server 2025
**********************************************/

USE master
GO

/*****************************************
 Habilitando Resource Governor (RG)
******************************************/
-- Verifica Status
SELECT is_enabled FROM sys.resource_governor_configuration

-- Para habilitar RG
-- Não precisa reiniciar o SQL Server
ALTER RESOURCE GOVERNOR RECONFIGURE

CREATE RESOURCE POOL RP_TempDB
WITH (MAX_CPU_PERCENT = 75,MAX_MEMORY_PERCENT = 75)

CREATE WORKLOAD GROUP RG_TempDB_Group USING RP_TempDB

SELECT * FROM sys.resource_governor_resource_pools
SELECT * FROM sys.resource_governor_workload_groups

/*************************************************
 Limitando o uso dos arquivos de dados da TempDB
**************************************************/

-- Pode limitar o uso da TempDB por valor absoluto em MB
ALTER WORKLOAD GROUP RG_TempDB_Group WITH (GROUP_MAX_TEMPDB_DATA_MB = 1)
ALTER RESOURCE GOVERNOR RECONFIGURE

ALTER WORKLOAD GROUP RG_TempDB_Group WITH (GROUP_MAX_TEMPDB_DATA_PERCENT = 10)
ALTER RESOURCE GOVERNOR RECONFIGURE

/**********************************************
 Cria Login para testar o limite
***********************************************/

-- Cria Server Role
CREATE SERVER ROLE [srv_role_TempDB]
GO
-- Cria Login de teste
CREATE LOGIN [Teste_Login] WITH PASSWORD=N'senha', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER SERVER ROLE [srv_role_TempDB] ADD MEMBER [Teste_Login]
GO

USE AdventureWorks
GO

CREATE USER [Teste_Login] FOR LOGIN [Teste_Login]
GO

ALTER ROLE [db_datareader] ADD MEMBER [Teste_Login]
GO
 
/************************************************************
 Função de Classificação
 https://learn.microsoft.com/en-us/sql/relational-databases/resource-governor/resource-governor-classifier-function?view=sql-server-ver17
*************************************************************/

USE master
GO

CREATE OR ALTER FUNCTION dbo.RG_ClassifierFunction()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN

DECLARE @Login sysname
SELECT @Login = SUSER_NAME()

IF (SELECT IS_SRVROLEMEMBER('srv_role_TempDB', @Login)) = 1
    RETURN 'RG_TempDB_Group'

RETURN 'default'
END
GO

/************* FIM Função **************/

-- Associa a função ao Resource Governor
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.RG_ClassifierFunction)
ALTER RESOURCE GOVERNOR RECONFIGURE

-- Retorna informações da Função de Classificação
SELECT a.classifier_function_id AS FuncaoClassificacao_id,
b.[name] AS FuncaoClassificacao,
a.is_enabled,
c.[definition] AS ddl
FROM sys.resource_governor_configuration a
JOIN sys.objects b ON a.classifier_function_id = b.[object_id]
JOIN sys.sql_modules c ON b.[object_id] = c.[object_id]


/**********************************
 Testando a Restrição na TempDB
 - Fazer login com "Teste_Login"
***********************************/
EXEC sp_helpdb 'tempdb'

SELECT * INTO #temptable FROM AdventureWorks.[Sales].[SalesOrderDetail]

SELECT * FROM #temptable

DROP TABLE #temptable

/******************************************************************
 Quantidade de vezes que atingiu o limite por Resource Pool
*******************************************************************/
SELECT a.group_id, a.[name], 
--b.group_max_tempdb_data_mb,
a.total_tempdb_data_limit_violation_count AS Qtd_Atingiu_Limite,
a.tempdb_data_space_kb AS TempDB_Limite_Atual,
a.peak_tempdb_data_space_kb AS TempDB_Limite_UltimaInicializacao
FROM sys.dm_resource_governor_workload_groups a
JOIN sys.resource_governor_workload_groups b
ON a.[name] = b.[name]

/***********************************
 Exclui objetos criados no HandsOn
************************************/
USE AdventureWorks
GO

DROP USER [Teste_Login]

USE master
GO

DROP LOGIN [Teste_Login]
DROP SERVER ROLE [srv_role_TempDB]
GO

ALTER RESOURCE GOVERNOR DISABLE
GO

ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = NULL)
GO

DROP FUNCTION IF EXISTS RG_ClassifierFunction
GO

DROP WORKLOAD GROUP RG_TempDB_Group
DROP RESOURCE POOL RP_TempDB
GO

-- Reiniciar o SQL Server