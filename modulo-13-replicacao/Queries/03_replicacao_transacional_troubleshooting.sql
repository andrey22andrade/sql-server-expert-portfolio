/*************************************************
 Hands On: Replicação Transacional Troubleshooting
**************************************************/

USE VendasDB
GO

EXEC sp_help 'dbo.Venda'

/*
sp_repladdcolumn
sp_repldropcolumn
*/

ALTER TABLE dbo.Venda ALTER COLUMN Valor_Total DECIMAL(10,2) NULL
ALTER TABLE dbo.Venda ADD Valor_Unitario DECIMAL(12,2) NULL
ALTER TABLE dbo.Venda DROP COLUMN Valor_Unitario

INSERT dbo.Venda (Data_Venda,ClienteID,ProdutoID,Valor_Total) VALUES (GETDATE()-1,2,2015,440.00)

SELECT * FROM VendasDB.dbo.Venda

EXEC sp_help 'dbo.Cliente'
ALTER TABLE dbo.Cliente ALTER COLUMN Nome CHAR(4000)
GO

-- Parar o JOB Log Reader
DECLARE @i INT = 5

WHILE @i <= 100000 BEGIN
	INSERT dbo.Cliente VALUES (@i,'Landry ' + LTRIM(STR(@i)),'4444-4444')
	SET @i += 1
END
GO

BACKUP DATABASE VendasDB TO DISK = 'C:\Backup\VendasDB.bak' WITH FORMAT,COMPRESSION

BACKUP LOG VendasDB TO DISK = 'C:\Backup\VendasDB01.trn' WITH FORMAT,COMPRESSION
BACKUP LOG VendasDB TO DISK = 'C:\Backup\VendasDB02.trn' WITH FORMAT,COMPRESSION
BACKUP LOG VendasDB TO DISK = 'C:\Backup\VendasDB03.trn' WITH FORMAT,COMPRESSION

--DELETE Cliente WHERE Telefone = '4444-4444' and Nome like 'Landry%'

SELECT * FROM dbo.Cliente

/************
 Exclui banco
*************/

USE master
GO

DROP DATABASE IF EXISTS VendasDB
GO