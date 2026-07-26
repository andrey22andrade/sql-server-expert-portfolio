/******************************
 - Gera atividade no SQL Server
*******************************/

/**************************************************
 - Abrir Performance Monitor

 - Abrir SqlQueryStress (Erik Ejlskov Jensen)
   https://github.com/ErikEJ/SqlQueryStress

     - Number of Iterations: Quantidade de vezes que a consulta será executada em cada Thread, isto é usuário virtual.
	 - Number of Threads: Quantidade de processos simultâneos, isto é quantidade de usuários virtuais.
***************************************************/

/********************** Gera atividade *****************************/

USE AdventureWorks
GO

-- DROP PROC spu_Stress_Memory
-- EXEC spu_Stress_Memory @i = 100
CREATE OR ALTER PROC spu_Stress_Memory
@i INT = 100
AS

DECLARE @TabTemp TABLE (
SalesOrderID INT NOT NULL,
OrderQty SMALLINT NOT NULL,
OrderDate DATETIME NOT NULL,
Description CHAR(1000) NULL,
StartDate DATETIME NOT NULL,
EndDate DATETIME NOT NULL)

DECLARE @Contador INT = 1
WHILE @Contador <= @i BEGIN
	INSERT @TabTemp
	SELECT d.SalesOrderID, d.OrderQty, h.OrderDate, cast(o.Description AS CHAR(1000)) AS Description, o.StartDate, o.EndDate
	FROM Sales.SalesOrderDetail d
	INNER JOIN Sales.SalesOrderHeader h ON d.SalesOrderID = h.SalesOrderID
	INNER JOIN Sales.SpecialOffer o ON d.SpecialOfferID = o.SpecialOfferID
	WHERE d.SpecialOfferID <> 1

	SELECT * FROM @TabTemp

	SET @Contador += 1
END
GO

/********************** FIM Gera atividade *****************************/

-- Exclui Procedure
DROP PROC spu_Stress_Memory
GO