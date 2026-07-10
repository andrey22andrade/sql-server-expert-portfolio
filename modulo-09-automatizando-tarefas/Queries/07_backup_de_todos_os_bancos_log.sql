/*******************************
 Backup de todos os bancos - LOG
********************************/

USE master
GO

/*******************************
 Criar JOB
 Step 1) Backup todos os bancos
********************************/
DECLARE @Caminho VARCHAR(4000), @Banco VARCHAR(500), @Compacta CHAR(1), @DataHora VARCHAR(20)
DECLARE @state_desc VARCHAR(200)
SET @Caminho = 'C:\_HandsOn_AdmSQL\Backup\LOG\'
SET @Compacta = 'S'

IF object_id('dbo.tmpBancosBackupLOG') IS NOT NULL
   DROP TABLE dbo.tmpBancosBackupLOG

SELECT name,state_desc 
INTO dbo.tmpBancosBackupLOG 
FROM sys.databases 
WHERE source_database_id IS NULL
AND state_desc = 'ONLINE' 
AND name NOT IN ('tempdb','model','msdb') 
AND recovery_model_desc <> 'SIMPLE'
ORDER BY name

DECLARE vCursor CURSOR FOR
SELECT name,state_desc FROM dbo.tmpBancosBackupLOG ORDER BY NAME

OPEN vCursor
FETCH NEXT FROM vCursor INTO @Banco,@state_desc

WHILE @@FETCH_STATUS = 0 BEGIN

   IF db_id(@Banco) IS NULL BEGIN
      PRINT '*** ERRO: DB_ID retornou NULL para o banco ' + @Banco 
      FETCH NEXT FROM vCursor INTO @Banco,@state_desc
      CONTINUE
   END

   IF @state_desc <> 'ONLINE' BEGIN
     PRINT '*** Banco: ' +  @Banco + ' está: ' + @state_desc
     FETCH NEXT FROM vCursor INTO @Banco,@state_desc 
     CONTINUE
   END

   PRINT 'Backup do Banco de Dados: ' + @Banco
   SET @DataHora = CONVERT(VARCHAR(1000),getdate(),112) + '_H' + replace(CONVERT(VARCHAR(8),getdate(),114),':','') 

   IF @Compacta = 'S'
      EXEC('BACKUP LOG [' + @Banco + ']  TO DISK = ''' + @Caminho + @Banco + '_' + @DataHora + '.trn'' WITH COMPRESSION')
   ELSE
      EXEC('BACKUP LOG [' + @Banco + ']  TO DISK = ''' + @Caminho + @Banco + '_' + @DataHora + '.trn''')

   IF @@ERROR <> 0 BEGIN
      PRINT '*** ERRO: backup do banco ' + @Banco + ' - Código de erro: ' + ltrim(str(@@error))
      FETCH NEXT FROM vCursor INTO @Banco,@state_desc
      CONTINUE
   END   
   
   FETCH NEXT FROM vCursor INTO @Banco,@state_desc
END

CLOSE vCursor
DEALLOCATE vCursor

IF object_id('dbo.tmpBancosBackupLOG') IS NOT NULL
   DROP TABLE dbo.tmpBancosBackupLOG
GO

/********************************************
 Step 2) Exclui Histórico dos Backups
*********************************************/
DECLARE @DelDate datetime
SET @DelDate = DATEADD(wk,-1,getdate())

EXECUTE master.dbo.xp_delete_file 0,N'C:\_HandsOn_AdmSQL\Backup\LOG',N'trn',@DelDate,0
GO