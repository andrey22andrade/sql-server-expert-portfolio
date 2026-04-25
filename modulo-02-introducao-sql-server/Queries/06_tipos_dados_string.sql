/***************************************************************************
Tipo de Dados String:

 - Diferença entre VARCHAR/NVARCHAR e CHAR/NCHAR
 - Funções para manipulação de Strings

***************************************************************************/

USE Aula
GO

/************************
 String CHAR e VARCHAR
*************************/ 
DROP TABLE IF EXISTS Produto
GO

CREATE TABLE Produto (
ProdutoID int NOT NULL,
Produto_Varchar varchar(50) NULL,
Produto_Char char(50) NULL,
Valor_Unitario decimal(10,2) NULL)
GO

INSERT Produto VALUES (1,'Monitor LCD 21"','Monitor LCD 21"', 780.00)
GO

SELECT ProdutoID, Produto_Varchar,Produto_Char
FROM Produto
GO

-- Monitor LCD 21"
-- Monitor LCD 21"                                   

/********************************************************************************************
 Funções String
 https://learn.microsoft.com/en-us/sql/t-sql/functions/string-functions-transact-sql?view=sql-server-ver16
*********************************************************************************************/

/***************************************************
 LEFT ( character_expression , integer_expression ) 
 RIGHT ( character_expression , integer_expression )
 SUBSTRING ( expression ,start , length )
****************************************************/

DECLARE @Produto VARCHAR(50) = 'Impressora HP Jato de Tinta'

SELECT @Produto, LEFT(@Produto,3), RIGHT(@Produto,5), SUBSTRING(@Produto,12,2)

/****************************************
 Funções que removem espaço em branco:
 LTRIM ( character_expression )
 RTRIM ( character_expression )
 TRIM ( [ characters FROM ] string )
*****************************************/
DECLARE @Nome VARCHAR(50) = '    Landry    '
DECLARE @Sobrenome VARCHAR(50) = '    Duailibe Salles'

SELECT @Nome + ' ' + @Sobrenome, trim(@Nome) + ' ' + ltrim(@Sobrenome)
GO

/**************
 Exclui Tabela
***************/
DROP TABLE Produto
GO