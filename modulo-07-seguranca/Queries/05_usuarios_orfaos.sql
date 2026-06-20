/*************************
 Hands On: Usuários Órfãos
**************************/

USE master
GO

-- Cria Login Teste01
CREATE LOGIN Teste01 WITH PASSWORD=N'1234', CHECK_POLICY=OFF
GO

/***********************
 Preparando Hands On 
***********************/
DROP DATABASE If EXISTS HandsOn
GO

CREATE DATABASE HandsOn
GO

USE HandsOn
GO

-- DROP TABLE dbo.Clientes 
CREATE TABLE dbo.Clientes 
(ClienteID INT NOT NULL PRIMARY KEY,Nome VARCHAR(50),Telefone VARCHAR(20))
GO

INSERT dbo.Clientes VALUES 
(1,'Jose','1111-1111'),
(2,'Maria','2222-2222'),
(3,'Maria','3333-3333')
GO

SELECT * FROM HandsOn.dbo.Clientes
GO

-- Cria Usuário de Banco de Dados
CREATE USER Teste01 FOR LOGIN Teste01
GO

ALTER ROLE db_datareader ADD MEMBER Teste01
ALTER ROLE db_datawriter ADD MEMBER Teste01
GO

/********************************** Fim Prepara Hands On *************************************/

/***************
 Backup
****************/
USE master
GO

BACKUP DATABASE HandsOn TO DISK = 'C:\_HandsOn_AdmSQL\Backup\HandsOn.bak' WITH format,compression
GO

/*******************************************
 Restore em outra instância
********************************************/
USE master
GO

RESTORE DATABASE HandsOn FROM DISK = 'C:\_HandsOn_AdmSQL\Backup\HandsOn.bak' with recovery,replace,
MOVE 'HandsOn' TO 'C:\MSSQL_Data_SQL02\HandsOn.mdf',
MOVE 'HandsOn_log' TO 'C:\MSSQL_Data_SQL02\HandsOn_log.ldf'

USE HandsOn
GO

/*****************************************
 Identificando Usuários Órfãos
 https://learn.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-change-users-login-transact-sql?view=sql-server-ver16
******************************************/
EXEC sp_change_users_login @Action = 'Report'

-- ou

SELECT dp.[sid] AS SID_UsuarioBD, dp.[name] AS UsuarioBD, 
sp.[sid] AS SID_Login, sp.[name] AS [Login],
dp.type_desc AS Tipo, dp.authentication_type_desc 
FROM sys.database_principals dp  
LEFT JOIN sys.server_principals sp ON dp.[sid] = sp.[sid]  
WHERE 1=1
and sp.sid IS NULL 
and dp.authentication_type_desc = 'INSTANCE'
ORDER BY UsuarioBD
GO

-- Cria Login Teste01
CREATE LOGIN Teste01 WITH PASSWORD = '1234', CHECK_POLICY=OFF
GO

-- Mostrar que continua sem link com Usuário de Banco

EXEC sp_change_users_login @Action = 'Report'

-- JOIN pelo nome
SELECT dp.[sid] AS SID_UsuarioBD, dp.[name] AS UsuarioBD, 
sp.[sid] AS SID_Login, sp.[name] AS [Login],
dp.[type_desc] AS Tipo, dp.authentication_type_desc 
FROM sys.database_principals dp  
LEFT JOIN sys.server_principals sp ON dp.[name] = sp.[name]
WHERE 1=1
--and sp.sid IS NULL 
and dp.authentication_type_desc = 'INSTANCE'
ORDER BY UsuarioBD
GO

/***********************************************************
 1) Resolvendo criando o Login com mesmo SID do usuário
************************************************************/
DROP LOGIN Teste01
GO

CREATE LOGIN Teste01 WITH PASSWORD = '1234',  CHECK_POLICY=OFF,
SID = 0xA513FAD81BDDDD46A6D73B780087A2B9

/***********************************************************
 2) Resolvendo utilizando sp_change_users_login
    - O problema é que altera o SID do Usuário para ficar
	  igual ao Login.
	- Toda vez que restaurar o banco, vai ter que fazer
	  o mesmo procedimento.
************************************************************/

EXEC sp_change_users_login @Action = 'Update_One', @UserNamePattern = 'Teste01', @LoginName = 'Teste01'

EXEC sp_change_users_login @Action = 'Auto_Fix', @UserNamePattern = 'Teste01', @LoginName = null

/***************************
 Remove objetos do Hands On
****************************/
USE master
GO

DROP DATABASE If EXISTS HandsOn
GO

DROP LOGIN Teste01
GO