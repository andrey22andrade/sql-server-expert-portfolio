/************************
 Hands On: Temporal Table
*************************/

USE Aula
GO

/***********************************************
 Cria Temporal Table
 - Mostrar como fica no Object Explorer
***********************************************/
DROP TABLE IF EXISTS dbo.Cliente
GO

CREATE TABLE dbo.Cliente (
Cliente_ID INT NOT NULL PRIMARY KEY,
Nome VARCHAR(50) NOT NULL,
RendaMensal DECIMAL(10,2) NULL,
RendaAnual AS RendaMensal * 12,
SysStartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
SysEndTime DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
PERIOD FOR SYSTEM_TIME (SysStartTime,SysEndTime))
WITH(SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Cliente_Hist))
GO

INSERT dbo.Cliente (Cliente_ID,Nome,RendaMensal)
VALUES
(1,'Paulo',10000.00),
(2,'Ana',20000.00),
(3,'Katia',30000.00)
GO

SELECT Cliente_ID, Nome, RendaMensal, RendaAnual, SysStartTime, SysEndTime
FROM dbo.Cliente
GO

-- Atualizações para popular histórico
UPDATE dbo.Cliente SET RendaMensal = 30100.00 WHERE Cliente_ID = 3
WAITFOR DELAY '00:00:05.000'
DELETE dbo.Cliente WHERE Cliente_ID = 2
UPDATE dbo.Cliente SET RendaMensal = 30200.00 WHERE Cliente_ID = 3
WAITFOR DELAY '00:00:05.000'
UPDATE dbo.Cliente SET RendaMensal = 30300.00 WHERE Cliente_ID = 3
GO

SELECT * FROM dbo.Cliente_Hist
GO

-- mostra todo o conteúdo da tabela Cliente incluindo todo o histórico de atualizações
SELECT Cliente_ID, Nome, RendaMensal, RendaAnual, SysStartTime, SysEndTime 
FROM dbo.Cliente
FOR SYSTEM_TIME ALL
ORDER BY Cliente_ID, SysStartTime 
GO

-- Reparem as 3 atualizações na coluna RendaMensal do cliente Katia
-- Com FOR SYSTEM_TIME AS OF podemos selecionar uma atualização do cliente Katia
SELECT * FROM dbo.Cliente
FOR SYSTEM_TIME AS OF '2017-07-16 19:55:09.4950260'
WHERE Cliente_ID = 3 
GO

DROP TABLE IF EXISTS dbo.Cliente
GO

/* Erro tem que desabilitar Temporal Table primeiro
Msg 13552, Level 16, State 1, Line 58
Drop table operation failed on table 'AdventureWorks.dbo.Cliente' because it is not supported operation on system-versioned temporal tables.
*/

ALTER TABLE dbo.Cliente SET (SYSTEM_VERSIONING = OFF)  
DROP TABLE IF EXISTS dbo.Cliente
DROP TABLE IF EXISTS dbo.Cliente_Hist
GO