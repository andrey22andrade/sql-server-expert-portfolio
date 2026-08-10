/***************************
 Hands ON: AlwaysOn no Azure
****************************/

USE master
GO

/****************** Prepara Demonstração ***********************/
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
(3,'Ana','3333-3333')
GO

SELECT * FROM HandsOn.dbo.Clientes
GO
--DELETE HandsOn.dbo.Clientes WHERE ClienteID in (4,5)

/****************** Fim Prepara Hands ON ***********************/

/****************** Inicio Demonstração Database Mirror ***************/
USE Master
GO

/************************** 
 BACKUP e RESTORE 
 - Criar pasta F:\Backup
***************************/
-- PRINCIPAL: Fazer Backup FULL e LOG

BACKUP DATABASE HandsOn TO DISK = 'F:\HandsOn\Backup\HandsOn.bak' 
WITH FORMAT,COMPRESSION,STATS=5

BACKUP LOG HandsOn TO DISK = 'F:\HandsOn\Backup\HandsOn_01.trn' 
WITH FORMAT,COMPRESSION,STATS=5

-- REPLICA: fazer Restore dos Backups FULL e LOG

RESTORE DATABASE HandsOn FROM DISK = 'F:\HandsOn\Backup\HandsOn.bak' 
WITH NORECOVERY,STATS=5

RESTORE LOG HandsOn FROM DISK = 'F:\HandsOn\Backup\HandsOn_01.trn' 
WITH NORECOVERY,STATS=5


/************************** TESTE de INSERT *************************/
SELECT * FROM HandsOn.dbo.Clientes

-- PRINCIPAL: Consulta tabela
INSERT HandsOn.dbo.Clientes VALUES (4,'Landry','4444-4444')
INSERT HandsOn.dbo.Clientes VALUES (5,'Carla','5555-5555')

SELECT * FROM HandsOn.dbo.Clientes

/***********************
 Habilitando DTC
************************/
ALTER AVAILABILITY GROUP [AG-CursoAdm] SET (DTC_SUPPORT = PER_DB)
ALTER AVAILABILITY GROUP [AG-CursoAdm] SET (DTC_SUPPORT = NONE)


/**********************
 Alterar Modo
***********************/
ALTER AVAILABILITY GROUP [AG-CursoAdm]
MODIFY REPLICA ON N'sql2-cursoadm' WITH (AVAILABILITY_MODE = SYNCHRONOUS_COMMIT)

-- Não pode estar com Automatic Failover
ALTER AVAILABILITY GROUP [AG-CursoAdm]
MODIFY REPLICA ON N'sql2-cursoadm' WITH (AVAILABILITY_MODE = ASYNCHRONOUS_COMMIT)

/*********************************************************
 Verificar se todos os bancos estão prontos para Failover
**********************************************************/
SELECT b.replica_server_name, database_name,is_failover_ready,is_database_joined, is_pending_secondary_suspend
FROM sys.dm_hadr_database_replica_cluster_states
JOIN sys.availability_replicas b ON b.replica_id = a.replica_id 


/***********************************************
 EXECUTAR Secundário: Failover
************************************************/

ALTER AVAILABILITY GROUP [AG-CursoAdm] FAILOVER
GO
-- Verificar o servidor ativo
SELECT @@SERVERNAME

CREATE TABLE Teste (col INT)
GO
DROP TABLE IF EXISTS Teste

/************************************
 Retornar movimentação dos dados
*************************************/
ALTER DATABASE [HandsOn]  SET HADR RESUME


/*******************************************
 Monitorar
********************************************/
SELECT n.group_name AS Grupo,n.replica_server_name AS 'Replica',
db_name(drs.database_id) AS Banco,
drs.synchronization_state_desc AS Sinc,
drs.synchronization_health_desc AS Estado 

FROM sys.dm_hadr_availability_replica_cluster_nodes n 
JOIN sys.dm_hadr_availability_replica_cluster_states cs ON n.replica_server_name = cs.replica_server_name 
JOIN sys.dm_hadr_availability_replica_states rs ON rs.replica_id = cs.replica_id 
JOIN sys.dm_hadr_database_replica_states drs ON rs.replica_id=drs.replica_id 
ORDER BY n.replica_server_name, db_name(drs.database_id)

-- Fila

SELECT r.replica_server_name AS Replica, 
CASE WHEN rs.is_primary_replica = 1 THEN 'Produção' ELSE 'Replica' END AS Papel,
db_name(rs.database_id) AS Banco, 
rs.synchronization_state_desc AS Estado,
ISNULL(CONVERT(VARCHAR(20),rs.last_commit_time,103) + ' ' + CONVERT(VARCHAR(20),
rs.last_commit_time,108),'n/a') AS UltimoCommit,
ISNULL(rs.log_send_rate,0) AS LogSendRate, rs.log_send_rate AS MediaEnvio_KbSec,
ISNULL(rs.log_send_queue_size,0) AS QueueSize, rs.redo_rate AS MediaRedo_KbSec

FROM sys.availability_replicas r
JOIN sys.dm_hadr_database_replica_states rs ON r.replica_id = rs.replica_id
WHERE r.replica_server_name in ('sql1-cursoadm','sql2-cursoadm')
ORDER BY r.replica_server_name, db_name(rs.database_id)

-- Retorna informações dos IPs do Lisener
SELECT	AV.name AS AVGName, AVGLis.dns_name AS ListenerName, 
AVGLis.ip_configuration_string_from_cluster AS ListenerIP
FROM sys.availability_group_listeners AVGLis
JOIN sys.availability_groups AV ON AV.group_id = AV.group_id

/******************************************
 Configurando ReadOnly Intent Routing
*******************************************/
SELECT replica_server_name, read_only_routing_url, secondary_role_allow_connections_desc
FROM sys.availability_replicas

-- Replica: sql1-cursoadm
ALTER AVAILABILITY GROUP [AG-CursoAdm]
MODIFY REPLICA ON 'sql1-cursoadm' WITH
(SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL))
 
ALTER AVAILABILITY GROUP [AG-CursoAdm]
MODIFY REPLICA ON 'sql1-cursoadm' WITH
(SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://sql1-cursoadm.cursoadm.com:1433'))

-- Replica: sql2-cursoadm
ALTER AVAILABILITY GROUP [AG-CursoAdm]
MODIFY REPLICA ON 'sql2-cursoadm' WITH
(SECONDARY_ROLE (ALLOW_CONNECTIONS = ALL))
 
ALTER AVAILABILITY GROUP [AG-CursoAdm]
MODIFY REPLICA ON 'sql2-cursoadm' WITH
(SECONDARY_ROLE (READ_ONLY_ROUTING_URL = N'TCP://sql2-cursoadm.cursoadm.com:1433'))

ALTER AVAILABILITY GROUP [AG-CursoAdm]
MODIFY REPLICA ON N'sql1-cursoadm' WITH (PRIMARY_ROLE(READ_ONLY_ROUTING_LIST = (N'sql2-cursoadm')))

-- Fazer o Failover e executar
ALTER AVAILABILITY GROUP [AG-CursoAdm]
MODIFY REPLICA ON N'sql2-cursoadm' WITH (PRIMARY_ROLE(READ_ONLY_ROUTING_LIST = (N'sql1-cursoadm')))

/***************************************************
 Testar
 - Tem que trocar o Default Database.
 - String de conexão: ApplicationIntent=ReadOnly
***************************************************/
select @@SERVERNAME

CREATE TABLE TESTE (col INT)
DROP TABLE IF EXISTS TESTE
GO