/**********************************************************************
 Hands On: Instant File Initialization

 Configurar:
 - Abrir o Local Security Policy: secpol.msc;
 - Expandir "Local Policies" e selecionar "User Rights Assignment";
 - Abrir "Perform volume maintenance tasks";
 - Adicionar a conta de serviço do SQL Server;
 - Reiniciar o serviço.

 Para verificar:
 - Log do serviço, pesquisar por "Instant File Initialization";
 - Consultar a View de sistema "sys.dm_server_services".
***********************************************************************/
USE master
GO

-- Verificando se o Instant File Initialization está habilitado.
SELECT * FROM  sys.dm_server_services 
GO