/*****************************
 Hands On: Provocando Deadlock
******************************/

USE Aula
GO

DROP TABLE IF EXISTS Funcionarios
GO

CREATE TABLE Funcionarios (PK INT PRIMARY KEY, Nome VARCHAR(50), Descricao VARCHAR(100), Status CHAR(1),Salario DECIMAL(10,2))
INSERT Funcionarios VALUES (1,'Fernando','Gerente','B',5600.00)
INSERT Funcionarios VALUES (2,'Ana Maria','Diretor','A',7500.00)
INSERT Funcionarios VALUES (3,'Lucia','Gerente','B',5600.00)
INSERT Funcionarios VALUES (4,'Pedro','Operacional','C',2600.00)
INSERT Funcionarios VALUES (5,'Carlos','Diretor','A',7500.00)
INSERT Funcionarios VALUES (6,'Carol','Operacional','C',2600.00)
INSERT Funcionarios VALUES (7,'Luana','Operacional','C',2600.00)
INSERT Funcionarios VALUES (8,'Lula','Diretor','A',7500.00)
INSERT Funcionarios VALUES (9,'Erick','Operacional','C',2600.00)
INSERT Funcionarios VALUES (10,'Joana','Operacional','C',2600.00)
GO

/************************
 hands On execução manual
*************************/

/* Conexão 1 */

SET DEADLOCK_PRIORITY normal
BEGIN TRAN
  SELECT Nome,PK FROM Funcionarios WHERE PK = 1
  UPDATE Funcionarios SET Nome = 'Fernando 1' WHERE PK = 1
  SELECT Nome,PK FROM Funcionarios WHERE PK = 1

  WAITFOR DELAY '00:00:10'

  UPDATE Funcionarios SET Nome = 'Ana Maria 2' WHERE PK = 2
ROLLBACK TRAN

/* Conexão 2 */

USE Aula
GO

SET DEADLOCK_PRIORITY LOW
BEGIN TRAN
  SELECT Nome,PK FROM Funcionarios WHERE PK = 2
  UPDATE Funcionarios SET Nome = 'Ana Maria 2' WHERE PK = 2
  SELECT Nome,PK FROM Funcionarios WHERE PK = 2
  UPDATE Funcionarios SET Nome = 'Fernando 1' WHERE PK = 1
ROLLBACK TRAN

/**********************
 Exclui tabela
***********************/
DROP TABLE IF EXISTS Funcionarios
GO