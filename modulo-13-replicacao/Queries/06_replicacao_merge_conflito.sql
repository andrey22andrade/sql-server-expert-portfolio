/*************************************
 Hands On: Replicação Merge - Conflito
**************************************/

USE VendasDB
GO

SELECT * FROM VendasDB.dbo.Cliente
SELECT * FROM VendasDB.dbo.Venda

/***************************
 Provocando conflito 1
****************************/
-- Executar no Publisher
UPDATE dbo.Cliente SET Telefone = 'AAAA-AAAA' WHERE ClienteID = 1 

-- Executar no Subscriber
UPDATE dbo.Cliente SET Telefone = 'BBBB-BBBB' WHERE ClienteID = 1 

/**********************************************
 Criando Alerta para Conflito
 - Nome: Replication: Merge Conflicts
 - Tipo do Alerta: performance condition alert
 - Objeto: SQL Replication Merge Conflicts
 - Contador: Conflicts/sec
 - rises above 0 
***********************************************/
-- Executar no Publisher
-- Executar no Publisher
UPDATE dbo.Cliente SET Telefone = 'CCCC-CCCC' WHERE ClienteID = 2 

-- Executar no Subscriber
UPDATE dbo.Cliente SET Telefone = 'DDDD-DDDD' WHERE ClienteID = 2