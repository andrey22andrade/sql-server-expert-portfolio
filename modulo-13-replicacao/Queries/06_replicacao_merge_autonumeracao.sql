/******************************************
 Hands On: Replicação Merge - Autonumeração
*******************************************/

USE VendasDB
GO

/*******************************
 Identity trata automaticamente
********************************/

-- Valor atual do Identity
SELECT IDENT_CURRENT('dbo.Venda') AS ValorAtual
 
SELECT * FROM dbo.Venda

-- Publisher
INSERT  dbo.Venda (Data_Venda,ClienteID,ProdutoID,Valor_Total) VALUES (getdate(),1,5001,100.00)

-- Subscriber
INSERT  dbo.Venda (Data_Venda,ClienteID,ProdutoID,Valor_Total) VALUES (getdate(),2,5002,200.00)

/****************************************************
 Sequence 
 - Para adicionar a tabela na Publicação
   acessar Propriedades/ Artigos
 - Gerar novo Snapshot "View Snapshot Agent Status"
*****************************************************/
CREATE SEQUENCE VendedorSeq START WITH 1 INCREMENT BY 10 -- Publisher (1 - 11 - 21 - 31 ...)
CREATE SEQUENCE VendedorSeq START WITH 2 INCREMENT BY 10 -- Subscriber (2 - 12 - 22 - 32 ...)

CREATE TABLE dbo.Vendedor (
VendedorID INT DEFAULT NEXT VALUE FOR VendedorSeq PRIMARY KEY,
Nome VARCHAR(100))
GO

-- Publisher
INSERT dbo.Vendedor (Nome) VALUES ('Jose')
INSERT dbo.Vendedor (Nome) VALUES ('Maria')

SELECT * FROM dbo.Vendedor

/*****************************
 Após primeira sincronia
******************************/
-- Publisher
INSERT dbo.Vendedor (Nome) VALUES ('Landry') 
INSERT dbo.Vendedor (Nome) VALUES ('Erick') 
INSERT dbo.Vendedor (Nome) VALUES ('Pedro') 
INSERT dbo.Vendedor (Nome) VALUES ('Marcelo') 

-- Subscriber
INSERT dbo.Vendedor (Nome) VALUES ('Paula') 
INSERT dbo.Vendedor (Nome) VALUES ('Luana') 
INSERT dbo.Vendedor (Nome) VALUES ('Carla') 
INSERT dbo.Vendedor (Nome) VALUES ('Tati') 

/****************************
 Exclui Tabela e Sequence
*****************************/
DROP TABLE IF EXISTS dbo.Vendedor
GO
DROP SEQUENCE VendedorSeq