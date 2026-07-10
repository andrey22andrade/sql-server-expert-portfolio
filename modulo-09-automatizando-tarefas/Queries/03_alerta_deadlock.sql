/********************************
 Hands On: Alerta Evento Deadlock
*********************************/

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

/***********************************
 Cria Alerta Evento 1205 - Deadlock
************************************/
EXEC msdb.dbo.sp_add_alert @name=N'Ocorrencia de Deadlock', @message_id=1205--, @delay_between_responses=1800
EXEC msdb.dbo.sp_add_notification @alert_name=N'Ocorrencia de Deadlock', @operator_name=N'DBA', @notification_method = 1

-- 1205 está com is_event_logged ZERO, não vai conseguir desparar o alerta!
SELECT * FROM sys.messages WHERE message_id = 1205

-- Altera is_event_logged para 1
EXEC sp_altermessage 1205, 'WITH_LOG', 'true' 

/**********************************
 Provoca Deadlock
***********************************/

/* Deadlock - A*/
SET DEADLOCK_PRIORITY normal
BEGIN TRAN
  SELECT Nome,PK FROM Funcionarios WHERE PK = 1

  UPDATE Funcionarios SET Nome = 'Fernando 1' WHERE PK = 1

  SELECT Nome,PK FROM Funcionarios WHERE PK = 1

  WAITFOR DELAY '00:00:10'

  UPDATE Funcionarios SET Nome = 'Ana Maria 2' WHERE PK = 2

ROLLBACK TRAN



/* Deadlock - B*/

SET DEADLOCK_PRIORITY low
BEGIN TRAN
  SELECT Nome,PK FROM Funcionarios WHERE PK = 2

  UPDATE Funcionarios SET Nome = 'Ana Maria 2' WHERE PK = 2

  SELECT Nome,PK FROM Funcionarios WHERE PK = 2

  UPDATE Funcionarios SET Nome = 'Fernando 1' WHERE PK = 1

ROLLBACK TRAN

-- Exclui Alerta

EXEC msdb.dbo.sp_delete_alert @name=N'Ocorrencia de Deadlock'
EXEC sp_altermessage 1205, 'WITH_LOG', 'false'

DROP TABLE If EXISTS Funcionarios
GO