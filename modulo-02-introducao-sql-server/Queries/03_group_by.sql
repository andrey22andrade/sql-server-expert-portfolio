/**** GROUP BY ****/

USE AdventureWorks
GO

/*********************************
 Funcao de Agregacao
**********************************/ 
SELECT COUNT(*) AS TotLinhas, COUNT(SalesPersonID) AS TotSalesPerson,
AVG(SalesPersonID) AS MediaComNULL, AVG(isnull(SalesPersonID,0)) AS MediaSemNULL
FROM Sales.SalesOrderHeader
GO

SELECT COUNT(*) AS TotLinhas
FROM Sales.SalesOrderHeader
GO
-- 31.465 linhas

SELECT COUNT(CurrencyRateID) AS TotLinhas
FROM Sales.SalesOrderHeader
GO

-- 13.976 linhas com NOT NULL na coluna CurrencyRateID

/**************************
 GROUP BY
***************************/ 
SELECT SalesPersonID,SUM(TotalDue) AS Total
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID
ORDER BY SalesPersonID
GO

-- Ordena pelos vendedores que venderam mais
SELECT SalesPersonID,SUM(TotalDue) AS Total
FROM Sales.SalesOrderHeader
GROUP BY SalesPersonID
ORDER BY Total DESC
GO

-- WHERE para remover o NULL
SELECT SalesPersonID,SUM(TotalDue) AS Total
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID
ORDER BY Total DESC
GO

-- HAVING filtro após o GROUP BY
SELECT SalesPersonID,SUM(TotalDue) AS Total
FROM Sales.SalesOrderHeader
WHERE SalesPersonID IS NOT NULL
GROUP BY SalesPersonID
HAVING SUM(TotalDue) > 5000000 
ORDER BY Total desc
GO