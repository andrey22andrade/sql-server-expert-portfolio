/************************
 Hands On: Row Versioning
*************************/

USE master
GO

DROP DATABASE IF EXISTS DB_Concorrencia
GO

CREATE DATABASE DB_Concorrencia
GO

ALTER DATABASE DB_Concorrencia SET RECOVERY SIMPLE
GO

USE DB_Concorrencia
GO

-- Cria Tabela para demonstração Snapshot Isolation Level
DROP TABLE IF EXISTS Funcionario
GO
CREATE TABLE Funcionario (PK INT PRIMARY KEY, Nome VARCHAR(50), Descricao VARCHAR(100), [Status] CHAR(1),Salario DECIMAL(10,2))
INSERT Funcionario VALUES (1,'Fernando','Gerente','B',5600.00)
INSERT Funcionario VALUES (2,'Ana Maria','Diretor','A',7500.00)
INSERT Funcionario VALUES (3,'Lucia','Gerente','B',5600.00)
INSERT Funcionario VALUES (4,'Pedro','Operacional','C',2600.00)
INSERT Funcionario VALUES (5,'Carlos','Diretor','A',7500.00)
INSERT Funcionario VALUES (6,'Carol','Operacional','C',2600.00)
INSERT Funcionario VALUES (7,'Luana','Operacional','C',2600.00)
INSERT Funcionario VALUES (8,'Lula','Diretor','A',7500.00)
INSERT Funcionario VALUES (9,'Erick','Operacional','C',2600.00)
INSERT Funcionario VALUES (10,'Joana','Operacional','C',2600.00)
GO

/****************************************************************************************
 Hands On 1: READ_COMMITTED padrão
  - Escrita bloqueia Leitura
*****************************************************************************************/

/******************
 Conexão 1
*******************/

SET TRANSACTION ISOLATION LEVEL READ COMMITTED

BEGIN TRAN
  UPDATE Funcionario SET Salario = 3000.00 WHERE PK = 10
  SELECT * FROM Funcionario WHERE PK = 10 -- Salario = 2600.00

ROLLBACK

/******************
 Conexão 2
*******************/
SELECT * FROM DB_Concorrencia.dbo.Funcionario -- with (nolock)
WHERE PK = 10 -- Salario = 3000.00

/****************************************************************************************
 Hands On 2: READ_COMMITTED_SNAPSHOT Isolation Level
  - Após a execução do ALTER DATABASE é imediatamente ativado o mecanismo de de versão.
  - Escrita não bloqueia Leitura
*****************************************************************************************/
USE master
GO

-- Habilita o banco para DB_Concorrencia Isolation Level
ALTER DATABASE DB_Concorrencia SET READ_COMMITTED_SNAPSHOT ON

-- Desabilita o READ_COMMITTED_SNAPSHOT no banco
ALTER DATABASE DB_Concorrencia SET READ_COMMITTED_SNAPSHOT OFF

-- Verifica Status do Banco
SELECT name AS Banco, 
snapshot_isolation_state,
snapshot_isolation_state_desc, 
is_read_committed_snapshot_on,
CASE is_read_committed_snapshot_on WHEN 1 THEN 'ON' ELSE 'OFF' END AS committed_snapshot_state_desc
FROM sys.databases
WHERE name = 'DB_Concorrencia'

/******************
 Conexão 1
*******************/
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

BEGIN TRAN
  UPDATE Funcionario SET Salario = 3000.00 WHERE PK = 10
  SELECT * FROM Funcionario WHERE PK = 10 -- Salario = 2600.00

COMMIT


/******************
 Conexão 2
*******************/
BEGIN TRAN
	SELECT * FROM DB_Concorrencia.dbo.Funcionario -- with (nolock)
	WHERE PK = 10 -- Salario = 3000.00

COMMIT

/****************************************************************************************
 Hands On 3: SNAPSHOT Isolation Level
  - Após o ALTER DATABASE, esta opção só é ativada quando todas AS transações iniciadas
    antes da instrução forem finalizadas!
*****************************************************************************************/

USE master
GO

-- Habilita o banco para SNAPSHOT Isolation Level
ALTER DATABASE DB_Concorrencia SET ALLOW_SNAPSHOT_ISOLATION ON

SET TRANSACTION ISOLATION LEVEL SNAPSHOT

-- Desabilita o banco para SNAPSHOT Isolation Level
ALTER DATABASE DB_Concorrencia SET ALLOW_SNAPSHOT_ISOLATION OFF

-- Verifica Status do Banco
SELECT name AS Banco, 
snapshot_isolation_state,
snapshot_isolation_state_desc, 
is_read_committed_snapshot_on,
CASE is_read_committed_snapshot_on WHEN 1 THEN 'ON' ELSE 'OFF' END AS committed_snapshot_state_desc
FROM sys.databases
WHERE name = 'DB_Concorrencia'

/******************
 Conexão 1
*******************/
SET TRANSACTION ISOLATION LEVEL SNAPSHOT

BEGIN TRAN
  UPDATE Funcionario SET Salario = 4000.00 WHERE PK = 10
  SELECT * FROM Funcionario WHERE PK = 10 -- Salario = 3000.00

COMMIT

BEGIN TRAN
  UPDATE Funcionario SET Salario = 8500.00 WHERE PK = 10
  SELECT * FROM Funcionario WHERE PK = 10 -- Salario = 4000.00

COMMIT

/******************
 Conexão 2
*******************/
SET TRANSACTION ISOLATION LEVEL SNAPSHOT

BEGIN TRAN
	SELECT * FROM DB_Concorrencia.dbo.Funcionario -- with (nolock)
	WHERE PK = 10

COMMIT


-- Exclui banco
USE master
GO

DROP DATABASE IF EXISTS DB_Concorrencia
GO