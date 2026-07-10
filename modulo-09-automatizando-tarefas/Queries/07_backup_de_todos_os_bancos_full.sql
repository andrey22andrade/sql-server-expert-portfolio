/*****************************
 Backup Todos os Bancos - FULL
******************************/

USE master
GO

/******************************************************
 Cria tabela para excluir bancos da rotina de Backup
*******************************************************/
DROP TABLE IF EXISTS DBA.dbo.DBA_BackupExcluir
GO
CREATE TABLE DBA.dbo.DBA_BackupExcluir (
Nomebanco sysname NOT NULL PRIMARY KEY)
GO
INSERT DBA.dbo.DBA_BackupExcluir VALUES ('CensoEscolar_DW')
GO

SELECT Nomebanco FROM DBA.dbo.DBA_BackupExcluir

/***************************************************
 Backup Master e MSDB
****************************************************/
DECLARE @Arquivo VARCHAR(4000),@Caminho VARCHAR(4000)
SET @Caminho = 'C:\_HandsOn_AdmSQL\Backup\'

SET @Arquivo = @Caminho + 'master_' + CONVERT(CHAR(8),GETDATE(),112)+ '_H' + replace(CONVERT(CHAR(8),GETDATE(),108),':','') + '.bak'
BACKUP DATABASE master TO DISK = @Arquivo WITH FORMAT, COMPRESSION

SET @Arquivo = @Caminho + 'msdb_' + CONVERT(CHAR(8),GETDATE(),112)+ '_H' + replace(CONVERT(CHAR(8),GETDATE(),108),':','') + '.bak'
BACKUP DATABASE msdb TO DISK = @Arquivo WITH FORMAT, COMPRESSION
GO

/****************************************************
 Criar JOB
 Step 1) Backup de todos os bancos para uma pasta
*****************************************************/ 

DECLARE @Caminho VARCHAR(4000), @Banco VARCHAR(500), @Compacta CHAR(1),@Arquivo VARCHAR(4000)
DECLARE @state_desc VARCHAR(200)
SET @Caminho = 'C:\_HandsOn_AdmSQL\Backup\FULL\' 
SET @Compacta = 'S'

IF object_id('dbo.tmpBancosBackupFULL') IS NOT NULL
   DROP TABLE dbo.tmpBancosBackupFULL

SELECT name,state_desc 
INTO dbo.tmpBancosBackupFULL 
FROM sys.databases 
WHERE source_database_id IS NULL
AND state_desc = 'ONLINE' 
AND name NOT IN ('tempdb','model') 
AND name NOT IN (SELECT Nomebanco FROM DBA.dbo.DBA_BackupExcluir)
ORDER BY name

DECLARE vCursor CURSOR FOR
SELECT name,state_desc FROM dbo.tmpBancosBackupFULL ORDER BY NAME

OPEN vCursor
FETCH NEXT FROM vCursor INTO @Banco, @state_desc

WHILE @@FETCH_STATUS = 0 BEGIN

   IF db_id(@Banco) IS NULL BEGIN
      PRINT '*** ERRO: DB_ID retornou NULL para o banco ' + @Banco 
      FETCH NEXT FROM vCursor INTO @Banco, @state_desc
      CONTINUE
   END
   
   IF @state_desc <> 'ONLINE' BEGIN
     PRINT '*** Banco: ' +  @Banco + ' está: ' + @state_desc
     FETCH NEXT FROM vCursor INTO @Banco,@state_desc 
     CONTINUE
  END

   PRINT 'Backup do Banco de Dados: ' + @Banco 
   SET @Arquivo = @Banco + '_' + CONVERT(CHAR(8),GETDATE(),112)+ '_H' + replace(CONVERT(CHAR(8),GETDATE(),108),':','')

   IF @Compacta = 'S'
      exec('BACKUP DATABASE [' + @Banco + ']  TO DISK = ''' + @Caminho + @Arquivo + '.bak'' WITH FORMAT, COMPRESSION')
   ELSE
      exec('BACKUP DATABASE [' + @Banco + ']  TO DISK = ''' + @Caminho + @Arquivo + '.bak'' WITH FORMAT')

   IF @@ERROR <> 0 BEGIN
      PRINT '*** ERRO: backup do banco ' + @Banco + ' - Código de erro: ' + ltrim(str(@@error))
      FETCH NEXT FROM vCursor INTO @Banco, @state_desc
      CONTINUE
   END   
   FETCH NEXT FROM vCursor INTO @Banco, @state_desc

END

CLOSE vCursor
DEALLOCATE vCursor

IF object_id('dbo.tmpBancosBackupFULL') IS NOT NULL
   DROP TABLE dbo.tmpBancosBackupFULL
GO


/********************************************
 Step 2) Exclui Histórico dos Backups
*********************************************/
DECLARE @DelDate datetime
SET @DelDate = DATEADD(wk,-4,GETDATE())

EXECUTE master.dbo.xp_delete_file 0,N'C:\_HandsOn_AdmSQL\Backup\FULL',N'bak',@DelDate,0
GO

/********************************************
 Indices para evitar Deadlock
*********************************************/
USE msdb
GO

CREATE NONCLUSTERED INDEX NIX_BackupSet_Media_set_id
ON dbo.backupset (media_set_id)
--WITH (online=on)
GO

CREATE NONCLUSTERED INDEX NNX_BackupSet_Backup_set_id_Media_set_id
ON dbo.backupset
(backup_set_id, media_set_id)
--WITH (online=on)
GO

Create index IX_Backupset_Backup_set_uuid
on backupset(backup_set_uuid)
--WITH (online=on)
GO

Create index IX_Bbackupset_Media_set_id
on backupset(media_set_id)
--WITH (online=on)
GO

Create index IX_Backupset_Backup_finish_date_INC_Media_set_id
on backupset(backup_finish_date)
INCLUDE (media_set_id)
--WITH (online=on)
GO

Create index IX_backupset_backup_start_date_INC_Media_set_id
on backupset(backup_start_date)
INCLUDE (media_set_id)
--WITH (online=on)
GO

Create index IX_Backupmediaset_Media_set_id
on backupmediaset(media_set_id)
--WITH (online=on)
GO

Create index IX_Backupfile_Backup_set_id
on Backupfile(backup_set_id)
--WITH (online=on)
GO

Create index IX_Backupmediafamily_Media_set_id
on Backupmediafamily(media_set_id)
--WITH (online=on)
GO