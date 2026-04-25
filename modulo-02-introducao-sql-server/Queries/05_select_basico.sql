/*******************************
         SELECT básico
********************************/

USE AdventureWorks
GO

SELECT * FROM Person.Person
GO

SELECT BusinessEntityID, LastName, FirstName, Title
FROM Person.Person
GO

/*****************************
 Filtros
******************************/
SELECT BusinessEntityID, LastName, FirstName, Title
FROM Person.Person
WHERE BusinessEntityID = 5
GO

SELECT BusinessEntityID, LastName, FirstName, Title
FROM Person.Person
WHERE Title = 'Ms.'
GO

SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE ListPrice >= 100
GO

/***********
 LIKE
************/
SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE '%Ball%'
GO

SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE '%Ball'
GO

SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE 'H_a_s%'
GO

SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE '[AC]%'
GO

SELECT ProductID, Name, Color, ListPrice
FROM Production.Product
WHERE Name LIKE '[A-C]%'
GO

/************ FIM LIKE ***************/

SELECT ProductID, Name, Color, ListPrice
FROM  Production.Product
WHERE (Name LIKE 'C%' OR Color = 'Blue') AND  (ListPrice > 100.00) 
GO

-- BETWEEN
SELECT ProductID, Name, Color, ListPrice
FROM  Production.Product
WHERE ListPrice BETWEEN 100 AND 1000
GO

--WHERE ListPrice >= 100 AND ListPrice <= 1000
-- 128 linhas

-- IN

SELECT ProductID, Name, Color, ListPrice
FROM  Production.Product
WHERE Color IN ('Blue', 'Black')
GO

--WHERE Color = 'Blue' or Color = 'Black'

/***********************
 NULL
************************/

SELECT ProductID, Name, Color, ListPrice
FROM  Production.Product
WHERE Color = NULL
GO
-- Zero linhas

SELECT ProductID, Name, Color, ListPrice
FROM  Production.Product
WHERE Color IS NULL

SELECT ProductID, Name, Color, ListPrice
FROM  Production.Product
WHERE Color IS NOT NULL

SELECT ProductID, Name, Color, isnull(Color,'n/a') AS Cores, ListPrice
FROM  Production.Product
GO

-- ORDER BY
SELECT ProductSubcategoryID,ProductID, Name, Color, ListPrice
FROM  Production.Product
ORDER BY ProductSubcategoryID, ListPrice DESC
GO

-- DISTINCT
SELECT Color FROM Production.Product
GO

SELECT distinct Color FROM Production.Product
GO