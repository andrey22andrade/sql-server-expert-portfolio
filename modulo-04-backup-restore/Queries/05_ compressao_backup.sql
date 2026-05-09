/*****************************
Opções de Compressão no Backup
******************************/

USE master
GO

BACKUP DATABASE AdventureWorksGR TO DISK = 'E:\_Aula\Backup\AdventureWorksGR_MS_XPRESS.bak'
WITH FORMAT, COMPRESSION, stats=5
-- 01:03 -> 1.825.064 KB

BACKUP DATABASE AdventureWorksGR TO DISK = 'E:\_Aula\Backup\AdventureWorksGR_ZSTD_LOW.bak'
WITH FORMAT, COMPRESSION (ALGORITHM = ZSTD, LEVEL = LOW), stats=5
-- 00:17 -> 1.876.880 KB

BACKUP DATABASE AdventureWorksGR TO DISK = 'E:\_Aula\Backup\AdventureWorksGR_ZSTD_MEDIUM.bak'
WITH FORMAT, COMPRESSION (ALGORITHM = ZSTD, LEVEL = MEDIUM), stats=5
-- 00:33 -> 1.604.132 KB

BACKUP DATABASE AdventureWorksGR TO DISK = 'E:\_Aula\Backup\AdventureWorksGR_ZSTD_HIGH.bak'
WITH FORMAT, COMPRESSION (ALGORITHM = ZSTD, LEVEL = HIGH), stats=5
-- 00:54 -> 1.576.436 KB

-- Qual nível é o padrão do ZSTD?
BACKUP DATABASE AdventureWorksGR TO DISK = 'E:\_Aula\Backup\AdventureWorksGR_ZSTD_Default.bak'
WITH FORMAT, COMPRESSION (ALGORITHM = ZSTD), stats=5
-- Padrão LOW

-- Qual método padrão do ZSTD?
BACKUP DATABASE AdventureWorksGR TO DISK = 'E:\_Aula\Backup\AdventureWorksGR_Default.bak'
WITH FORMAT, COMPRESSION, stats=5
-- Padrão LOW

/*
				Tempo	Tamanho KB
------------------------------------
MS_XPRESS		01:03	1.825.064
ZSTD LOW		00:17	1.876.880
ZSTD MEDIUM		00:33	1.604.132
ZSTD HIGH		00:54	1.576.436

*/

/***********************************
 Configuração padrão da instância
************************************/
-- Valor 0 padrão de instalação utiliza MS_XPRESS
-- Valor 1 utiliza compressão no Backup por padrão
EXEC sys.sp_configure 'backup compression default', 1
RECONFIGURE

/*******************************************
 Algoritmo de compressão

 Valor 0 padrão de instalação utiliza MS_XPRESS
 Valor 1 MS_XPRESS
 Valor 2 Intel QAT
 Valor 3 ZSTD
********************************************/
EXEC sys.sp_configure 'backup compression algorithm', 1
RECONFIGURE

EXEC sys.sp_configure 'backup compression algorithm', 3
RECONFIGURE

BACKUP DATABASE AdventureWorksGR TO DISK = 'C:\LIVES\Backup\AdventureWorksGR.bak'
WITH FORMAT, stats=5

/**************************************************
 Trace Flag 3042 desabilita a verificação de espaço 
 livre no disco antes de iniciar um backup.

 Disponível desde o SQL Server 2008
***************************************************/
DBCC TRACEON(3042) -- sessão
DBCC TRACEON(3042, -1) -- instância

BACKUP DATABASE AdventureWorksGR TO DISK = 'C:\LIVES\Backup\AdventureWorksGR.bak'
WITH FORMAT, stats=5
GO