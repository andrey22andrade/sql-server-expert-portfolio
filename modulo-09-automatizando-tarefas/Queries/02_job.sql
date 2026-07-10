/**************
 Hands On: JOBs
***************/

/****************************************************
 1a Tarefa - Backup Bancos Sistema
****************************************************/

DECLARE @Path VARCHAR(4000) = 'C:\_HandsOn_AdmSQL\Backup\'
DECLARE @Arquivo VARCHAR(4000)

SET @Arquivo = @Path + 'master_' + CONVERT(CHAR(8),GETDATE(),112)+ '_H' + REPLACE(CONVERT(char(8),GETDATE(),108),':','') + '.bak'
BACKUP DATABASE master TO DISK = @Arquivo WITH FORMAT, COMPRESSION

set @Arquivo = @Path + 'msdb_' + CONVERT(char(8),GETDATE(),112)+ '_H' + REPLACE(CONVERT(char(8),GETDATE(),108),':','') + '.bak'
BACKUP DATABASE msdb TO DISK = @Arquivo WITH FORMAT, COMPRESSION

/********************************************
 2a Tarefa - Exclui Histórico dos Backups
*********************************************/

DECLARE @DelDate DATETIME
SET @DelDate = DATEADD(wk,-4,GETDATE())

EXECUTE master.dbo.xp_delete_file 0,N'C:\_HandsOn_AdmSQL\Backup',N'bak',@DelDate,0

/********************************************
 Indices para evitar Deadlock
*********************************************/

USE msdb
GO

CREATE NONCLUSTERED INDEX NIX_BackupSet_Media_set_id
ON dbo.backupset (media_set_id)
--With (online=on)

CREATE NONCLUSTERED INDEX NNX_BackupSet_Backup_set_id_Media_set_id
ON dbo.backupset
(backup_set_id, media_set_id)
--With (online=on)

CREATE INDEX IX_Backupset_Backup_set_uuid
ON backupset(backup_set_uuid)
--With (online=on)

CREATE INDEX IX_Bbackupset_Media_set_id
ON backupset(media_set_id)
--With (online=on)

CREATE INDEX IX_Backupset_Backup_finish_date_INC_Media_set_id
ON backupset(backup_finish_date)
INCLUDE (media_set_id)
--With (online=on)

CREATE INDEX IX_backupset_backup_start_date_INC_Media_set_id
ON backupset(backup_start_date)
INCLUDE (media_set_id)
--With (online=on)

CREATE INDEX IX_Backupmediaset_Media_set_id
ON backupmediaset(media_set_id)
--With (online=on)

CREATE INDEX IX_Backupfile_Backup_set_id
ON Backupfile(backup_set_id)
--With (online=on)

CREATE INDEX IX_Backupmediafamily_Media_set_id
ON Backupmediafamily(media_set_id)
--With (online=on)