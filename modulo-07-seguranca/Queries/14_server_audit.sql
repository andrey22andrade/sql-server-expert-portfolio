/**************************
 Hands On: SQL Server Audit
***************************/

USE master
GO

-- Views de sistema
SELECT parent_class_desc,class_desc,name
FROM sys.dm_audit_actions
ORDER BY parent_class_desc,class_desc ,name
GO

SELECT * FROM sys.dm_audit_class_type_map
GO

/************************************************************************************
 Auditoria para o Event Viewer do Windows ou arquivo

 Criar pasta em C:\_HandsOn_AdmSQL\_DBA_Monitora

 CREATE SERVER AUDIT... ON_FAILURE = { CONTINUE | SHUTDOWN | FAIL_OPERATION }
 - No SQL 2012 nova opção de falhar a operação se a auditoria não funcionar, 
   no lugar de shutdown do servidor!

 - Novo SQL 2012 USER_DEFINED_AUDIT_GROUP, onde uma aplicação pode provocar um 
   evento com sp_audit_write e registrar na auditoria
*************************************************************************************/

USE master
GO

-- DROP SERVER AUDIT TesteAudit_Auditoria
CREATE SERVER AUDIT TesteAudit_Auditoria 
TO FILE (FILEPATH = 'C:\_HandsOn_AdmSQL\_DBA_Monitora')
--TO APPLICATION_LOG
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE)
GO

/***********************************
 Cria tabelas para Hands On
************************************/

USE Aula
GO

DROP TABLE IF EXISTS Aula.dbo.Person
GO

SELECT BusinessEntityID, PersonType, NameStyle, Title, FirstName, MiddleName, LastName, 
Suffix, EmailPromotion, rowguid, ModifiedDate
INTO Aula.dbo.Person FROM AdventureWorks.Person.Person
GO

DROP TABLE IF EXISTS Aula.dbo.Product
GO
SELECT * INTO Aula.dbo.Product FROM AdventureWorks.Production.Product
GO

/**********************************************
 Define auditoria para operação de SELECT
***********************************************/
-- DROP DATABASE AUDIT SPECIFICATION TesteAudit_dbo_SELECT
CREATE DATABASE AUDIT SPECIFICATION TesteAudit_dbo_SELECT
FOR SERVER AUDIT TesteAudit_Auditoria
ADD (SELECT ON SCHEMA::dbo BY public), 
ADD (USER_DEFINED_AUDIT_GROUP)
GO

-- Habilitando a Auditoria na MASTER
USE master
GO

ALTER SERVER AUDIT TesteAudit_Auditoria WITH (STATE = ON)
GO

-- Habilitando a Auditoria no banco Aula
USE Aula
GO

ALTER DATABASE AUDIT SPECIFICATION TesteAudit_dbo_SELECT WITH (STATE = ON)
GO
  
-- Consultando Metadata
SELECT * FROM sys.server_audits
SELECT * FROM sys.dm_server_audit_status
SELECT * FROM sys.server_file_audits
SELECT * FROM sys.database_audit_specifications
SELECT * FROM sys.database_audit_specification_details
GO

-- Provocar escrita na Auditoria
SELECT * FROM Aula.sys.tables -- Nao gera auditoria

SELECT * FROM Aula.dbo.Product
GO

/***************************************************************************
 Parâmetros:
 1) Path
 2) Primeiro arquivo a ser lido, se NULL ou DEFAULT lê do primeiro
 3) Número do Registro dentro do arquivo, se NULL ou DEFAULT lê do primeiro
****************************************************************************/
SELECT * FROM sys.fn_get_audit_file('C:\_HandsOn_AdmSQL\_DBA_Monitora\*',NULL,NULL)
GO

/****************************
 Retirar auditoria
*****************************/
USE Aula
GO

ALTER DATABASE AUDIT SPECIFICATION TesteAudit_dbo_SELECT WITH (STATE = OFF)
GO

DROP DATABASE AUDIT SPECIFICATION TesteAudit_dbo_SELECT
GO

USE master
GO

ALTER SERVER AUDIT TesteAudit_Auditoria WITH (STATE = OFF)
GO

DROP SERVER AUDIT TesteAudit_Auditoria
GO

-- Exlui tabelas
DROP TABLE IF EXISTS Aula.dbo.Person
DROP TABLE IF EXISTS Aula.dbo.Product
GO