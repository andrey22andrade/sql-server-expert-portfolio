/**********************
 Movendo Arquivo de Log
***********************/

USE master
GO

-- Cria banco DB_HandsOn
CREATE DATABASE DB_HandsOn
GO

SELECT name, physical_name 
FROM sys.master_files 
WHERE database_id = DB_ID('DB_HandsOn')

ALTER DATABASE DB_HandsOn SET OFFLINE 
WITH ROLLBACK IMMEDIATE


ALTER DATABASE DB_HandsOn MODIFY FILE 
(name = 'DB_HandsOn_log', 
filename = 'C:\_HandsOn_AdmSQL\DB_HandsOn_log.ldf')

-- Copiar o arquivo para nova localização

ALTER DATABASE DB_HandsOn SET ONLINE 


/*****************************
 Exclui Banco
******************************/
DROP DATABASE IF EXISTS DB_HandsOn
GO