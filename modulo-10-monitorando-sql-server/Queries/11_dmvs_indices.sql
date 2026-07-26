/*************************************
 Hands ON: DMVs Informações de Índices
**************************************/

USE AdventureWorks
GO

/*************************************
 Uso de Indices
**************************************/
SELECT * FROM sys.dm_db_index_usage_stats
SELECT * FROM sys.indexes

SELECT OBJECT_NAME(a.[object_id]) AS Tabela, b.[name] AS Indice, b.[type_desc] AS Tipo,
CASE WHEN b.is_primary_key = 1 THEN'Sim' ELSE 'Não' END AS PK,
a.user_seeks AS Seeks, a.user_scans AS Scans, a.user_lookups AS Lookups,-- a.user_updates AS Updates
a.user_seeks + a.user_scans + a.user_lookups AS TotalOperacoes

FROM sys.dm_db_index_usage_stats a
JOIN sys.indexes b ON a.[object_id] = b.[object_id] AND a.index_id = b.index_id
WHERE OBJECTPROPERTY(a.[object_id],'IsUserTable') = 1
AND b.[name] IS NOT NULL
AND b.[type_desc] <> 'CLUSTERED' 
ORDER BY TotalOperacoes

/**************************************
 Lista Índices com Chaves e Include
***************************************/
SELECT * FROM sys.index_columns
SELECT * FROM sys.columns

SELECT DISTINCT object_name(i.object_id) AS Tabela,i.name AS Indice,
(SELECT DISTINCT stuff((SELECT ', ' + c.name
 FROM sys.index_columns ic1 
 JOIN sys.columns c ON ic1.object_id = c.object_id AND ic1.column_id = c.column_id
 WHERE ic1.index_id = ic.index_id AND ic1.object_id = i.object_id AND ic1.index_id = i.index_id
       AND ic1.is_included_column = 0
 ORDER BY key_ordinal FOR XML PATH('')),1,2,'')
 FROM sys.index_columns ic 
 WHERE object_id=i.object_id AND index_id=i.index_id) AS Colunas_Chave,

ISNULL((SELECT DISTINCT stuff((SELECT ', ' + c.name
 FROM sys.index_columns ic1 
 JOIN sys.columns c ON ic1.object_id = c.object_id AND ic1.column_id = c.column_id
 WHERE ic1.index_id = ic.index_id AND ic1.object_id = i.object_id AND ic1.index_id = i.index_id
       AND ic1.is_included_column = 1
 ORDER BY key_ordinal FOR XML PATH('')),1,2,'')
 FROM sys.index_columns ic 
 WHERE object_id=i.object_id AND index_id=i.index_id),'') AS Colunas_Include

FROM sys.indexes i 
JOIN sys.index_columns ic ON i.object_id=ic.object_id AND i.index_id=ic.index_id 
WHERE OBJECTPROPERTY(i.[object_id],'IsUserTable') = 1
ORDER BY Tabela, Indice, Colunas_Chave, Colunas_Include 

-- Cria Índices duplicados
CREATE INDEX ix_Landry_Address_StateProvinceID_v1
ON Person.[Address] (StateProvinceID)
INCLUDE (AddressLine1, AddressLine2, City)

CREATE INDEX ix_Landry_Address_StateProvinceID_v2
ON Person.[Address] (StateProvinceID)
INCLUDE (AddressLine1, AddressLine2, City)

/*******************************************************************
 Cria coluna para identificar índices com mesma Chave e Include
********************************************************************/
;WITH CTE_Indices AS (
SELECT DISTINCT object_name(i.object_id) AS Tabela,i.name AS Indice,
(SELECT DISTINCT stuff((SELECT ', ' + c.name
 FROM sys.index_columns ic1 
 JOIN sys.columns c ON ic1.object_id = c.object_id AND ic1.column_id = c.column_id
 WHERE ic1.index_id = ic.index_id AND ic1.object_id = i.object_id AND ic1.index_id = i.index_id
       AND ic1.is_included_column = 0
 ORDER BY key_ordinal FOR XML PATH('')),1,2,'')
 FROM sys.index_columns ic 
 WHERE object_id=i.object_id AND index_id=i.index_id) AS Colunas_Chave,

ISNULL((SELECT DISTINCT stuff((SELECT ', ' + c.name
 FROM sys.index_columns ic1 
 JOIN sys.columns c ON ic1.object_id = c.object_id AND ic1.column_id = c.column_id
 WHERE ic1.index_id = ic.index_id AND ic1.object_id = i.object_id AND ic1.index_id = i.index_id
       AND ic1.is_included_column = 1
 ORDER BY key_ordinal FOR XML PATH('')),1,2,'')
 FROM sys.index_columns ic 
 WHERE object_id=i.object_id AND index_id=i.index_id),'') AS Colunas_Include

FROM sys.indexes i 
JOIN sys.index_columns ic ON i.object_id=ic.object_id AND i.index_id=ic.index_id 
WHERE OBJECTPROPERTY(i.[object_id],'IsUserTable') = 1
AND i.[type_desc] in ('NONCLUSTERED','CLUSTERED'))

SELECT ROW_NUMBER() OVER (PARTITION BY Tabela, Colunas_Chave, Colunas_Include ORDER BY Indice) AS Ordem,
Tabela, Indice, Colunas_Chave, Colunas_Include
FROM CTE_Indices
 
/*******************************************************************
 Retorna Índices Duplicados, com mesma Chave e Include
********************************************************************/
;WITH CTE_Indices AS (
SELECT DISTINCT object_name(i.object_id) AS Tabela,i.name AS Indice,
(SELECT DISTINCT stuff((SELECT ', ' + c.name
 FROM sys.index_columns ic1 
 JOIN sys.columns c ON ic1.object_id = c.object_id AND ic1.column_id = c.column_id
 WHERE ic1.index_id = ic.index_id AND ic1.object_id = i.object_id AND ic1.index_id = i.index_id
       AND ic1.is_included_column = 0
 ORDER BY key_ordinal FOR XML PATH('')),1,2,'')
 FROM sys.index_columns ic 
 WHERE object_id=i.object_id AND index_id=i.index_id) AS Colunas_Chave,

ISNULL((SELECT DISTINCT stuff((SELECT ', ' + c.name
 FROM sys.index_columns ic1 
 JOIN sys.columns c ON ic1.object_id = c.object_id AND ic1.column_id = c.column_id
 WHERE ic1.index_id = ic.index_id AND ic1.object_id = i.object_id AND ic1.index_id = i.index_id
       AND ic1.is_included_column = 1
 ORDER BY key_ordinal FOR XML PATH('')),1,2,'')
 FROM sys.index_columns ic 
 WHERE object_id=i.object_id AND index_id=i.index_id),'') AS Colunas_Include

FROM sys.indexes i 
JOIN sys.index_columns ic ON i.object_id=ic.object_id AND i.index_id=ic.index_id 
WHERE OBJECTPROPERTY(i.[object_id],'IsUserTable') = 1
AND i.[type_desc] in ('NONCLUSTERED','CLUSTERED')),

CTE_Duplicado AS (
SELECT ROW_NUMBER() OVER (PARTITION BY Tabela, Colunas_Chave, Colunas_Include ORDER BY Indice) AS Ordem,
Tabela, Indice, Colunas_Chave, Colunas_Include
FROM CTE_Indices)
 
SELECT *
FROM CTE_Duplicado
WHERE Ordem > 1


/**********************
 Exclui Índices
***********************/
DROP INDEX Person.[Address].ix_Landry_Address_StateProvinceID_v1
DROP INDEX Person.[Address].ix_Landry_Address_StateProvinceID_v2
GO