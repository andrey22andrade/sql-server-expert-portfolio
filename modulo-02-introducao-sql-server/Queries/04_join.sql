/*******************************
             JOIN
********************************/
USE Aula
GO

-- Cria duas tabelas para Hands On
DROP TABLE IF EXISTS dbo.Vendedor
GO

DROP TABLE IF EXISTS dbo.Venda
GO

CREATE TABLE dbo.Vendedor (VendedorId int, Vendedor varchar(100))
CREATE TABLE dbo.Venda (VendaID int, VendedorID int, ProdutoID int, Qtd int, Valor decimal(10,2))
GO

INSERT dbo.Vendedor VALUES (1,'Jose')
INSERT dbo.Vendedor VALUES (2,'Pedro')
INSERT dbo.Vendedor VALUES (3,'Lucia')
INSERT dbo.Vendedor VALUES (4,'Ana')
GO

INSERT dbo.Venda VALUES (100,1,10,5,1000.00)
INSERT dbo.Venda VALUES (101,5,20,3,1500.00)
INSERT dbo.Venda VALUES (101,6,30,2,2500.00)
GO

SELECT * FROM dbo.Vendedor 
SELECT * FROM dbo.Venda
GO

SELECT * FROM dbo.Vendedor a JOIN dbo.Venda b on a.VendedorId = b.VendedorID
SELECT * FROM dbo.Vendedor a LEFT JOIN dbo.Venda b on a.VendedorId = b.VendedorID
SELECT * FROM dbo.Vendedor a RIGHT JOIN dbo.Venda b on a.VendedorId = b.VendedorID
SELECT * FROM dbo.Vendedor a FULL JOIN dbo.Venda b on a.VendedorId = b.VendedorID
GO

/**************
 CROSS JOIN 
***************/
DROP TABLE IF EXISTS Campeonato
GO

CREATE TABLE Campeonato (Grupo CHAR(1), Time VARCHAR(30))
GO

INSERT Campeonato VALUES ('A','Flamengo')
INSERT Campeonato VALUES ('A','Vasco')
INSERT Campeonato VALUES ('A','América')
INSERT Campeonato VALUES ('A','Boavista')
INSERT Campeonato VALUES ('A','Volta Redonda')
INSERT Campeonato VALUES ('A','Nova Iguaçu')
INSERT Campeonato VALUES ('A','Americano')
INSERT Campeonato VALUES ('A','Resende')
GO

INSERT Campeonato VALUES ('B','Botafogo')
INSERT Campeonato VALUES ('B','Fluminense')
INSERT Campeonato VALUES ('B','Bangu')
INSERT Campeonato VALUES ('B','Olaria')
INSERT Campeonato VALUES ('B','Madureira')
INSERT Campeonato VALUES ('B','Cabofriense')
INSERT Campeonato VALUES ('B','Macaé')
INSERT Campeonato VALUES ('B','Duque de Caxias')
GO

SELECT * FROM Campeonato ORDER BY Grupo
GO

-- Jogos Grupo A
SELECT c1.Time Casa, c2.Time Visitante
FROM Campeonato c1 CROSS JOIN  Campeonato c2
WHERE c1.Time <> c2.Time AND c1.Grupo = 'A' AND c2.Grupo = 'A'
GO

-- Jogos Grupo B
SELECT c1.Time Casa, c2.Time Visitante
FROM Campeonato c1 CROSS JOIN  Campeonato c2
WHERE c1.Time <> c2.Time AND c1.Grupo = 'B' AND c2.Grupo = 'B'
GO

/*********************
 Apaga tabelas
**********************/
DROP TABLE IF EXISTS Campeonato
DROP TABLE IF EXISTS dbo.Vendedor
DROP TABLE IF EXISTS dbo.Venda
GO