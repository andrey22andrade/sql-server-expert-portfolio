/**********************************************
 Hands On: Trigger Logon para restringir acesso
***********************************************/

USE master
GO

/****************************************
 Trigger Logon negar acesso via Excel
*****************************************/

CREATE TRIGGER Trigger_Logon_SSMS
ON ALL SERVER FOR LOGON
AS

IF APP_NAME() LIKE 'Microsoft SQL Server Management Studio%' and ORIGINAL_LOGIN() = 'SSRS'
BEGIN
	PRINT 'O Login ' + ORIGINAL_LOGIN() + ' não pode acessar o servidor pela aplicação ' + APP_NAME() + '!'
	ROLLBACK
END
GO

/*********************** Fim Trigger ************************/

EXEC sp_readerrorlog
GO

-- Exclui Trigger
USE master
GO
DROP TRIGGER Trigger_Logon_SSMS ON ALL SERVER
GO