/*************************************************
 Hands On: gera atividade no banco Adventure Works
**************************************************/

USE AdventureWorks
GO

-- Gera Atividade
SELECT count(*) FROM AdventureWorks.Person.Person
GO

SELECT * FROM AdventureWorks.Person.Person WHERE LastName = 'Abbas'
GO