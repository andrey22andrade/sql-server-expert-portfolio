/*******************************
 Backup de todos os bancos - DIF
********************************/ 

USE master
GO

/*******************************
 Criar JOB
 Step 1) Backup todos os Bancos
********************************/
DECLARE @Caminho VARCHAR(4000), @Banco VARCHAR(500), @Compacta CHAR(1),@Arquivo VARCHAR(4000)
DECLARE @state_desc VARCHAR(200)
SET @Caminho = 'C:\_HandsOn_AdmSQL\Backup\DIF\' 
SET @Compacta = 'S'

IF object_id('dbo.tmpBancosBackupDIF') IS NOT NULL
   DROP TABLE dbo.tmpBancosBackupDIF

SELECT name,state_desc 
INTO dbo.tmpBancosBackupDIF 
FROM sys.databases 
WHERE source_database_id is null
AND state_desc = 'ONLINE' 
AND name NOT IN ('tempdb','master','model','msdb') 
AND name NOT IN (SELECT Nomebanco FROM DBA.dbo.DBA_BackupExcluir)
ORDER BY name

DECLARE vCursor CURSOR FOR
SELECT name,state_desc FROM dbo.tmpBancosBackupDIF ORDER BY NAME

OPEN vCursor
FETCH NEXT FROM vCursor INTO @Banco,@state_desc

WHILE @@FETCH_STATUS = 0 BEGIN

   IF db_id(@Banco) is null BEGIN
      print '*** ERRO: DB_ID retornou NULL para o banco ' + @Banco 
      FETCH NEXT FROM vCursor INTO @Banco,@state_desc
      CONTINUE
   END

   IF @state_desc <> 'ONLINE' begin
     PRINT '*** Banco: ' +  @Banco + ' está: ' + @state_desc
     FETCH NEXT FROM vCursor INTO @Banco,@state_desc 
     CONTINUE
   END

   
   PRINT 'Backup do Banco de Dados: ' + @Banco 
   SET @Arquivo = @Banco + '_' + CONVERT(CHAR(8),GETDATE(),112)+ '_H' + REPLACE(CONVERT(CHAR(8),GETDATE(),108),':','') + '.dif'

   IF @Compacta = 'S'
      EXEC('BACKUP DATABASE [' + @Banco + ']  TO DISK = ''' + @Caminho + @Arquivo + ''' WITH FORMAT, COMPRESSION, DIFFERENTIAL')
   ELSE
      EXEC('BACKUP DATABASE [' + @Banco + ']  TO DISK = ''' + @Caminho + @Arquivo + ''' WITH FORMAT, DIFFERENTIAL')

   IF @@ERROR <> 0 BEGIN
      PRINT '*** ERRO: backup do banco ' + @Banco + ' - Código de erro: ' + ltrim(str(@@error))
      FETCH NEXT FROM vCursor INTO @Banco,@state_desc
      CONTINUE
   END   
  
   FETCH NEXT FROM vCursor INTO @Banco,@state_desc
END

CLOSE vCursor
DEALLOCATE vCursor

IF object_id('dbo.tmpBancosBackupDIF') IS NOT NULL
   DROP TABLE dbo.tmpBancosBackupDIF
GO

/********************************************
 Step 2) Exclui Histórico dos Backups
*********************************************/
DECLARE @DelDate datetime
SET @DelDate = DATEADD(wk,-4,GETDATE())

EXECUTE master.dbo.xp_delete_file 0,N'C:\_HandsOn_AdmSQL\Backup\DIF',N'dif',@DelDate,0
GO