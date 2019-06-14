
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPT_USUARIOS]
	@ID INT = null,
	@OPERACION TINYINT = 4,
	@NUMERO_CEDULA VARCHAR(100) = null,
	@NOMBRE VARCHAR(100) = null,
	@PRIMER_APELLIDO VARCHAR(70) = null,
	@SEGUNDO_APELLIDO VARCHAR(70) = null,
	@USER_NAME VARCHAR(100)= null,
	@PASSWORD VARCHAR(100) = NULL	
AS
BEGIN
	
	SET NOCOUNT ON;
-----------------------------------------------------
	--INSERTAR
-----------------------------------------------------
	
	IF @OPERACION = 0
	BEGIN

		INSERT INTO USUARIOS 
		VALUES(
		@USER_NAME,
		@PASSWORD,
		@NOMBRE,
		@PRIMER_APELLIDO,
		@SEGUNDO_APELLIDO,
		@NUMERO_CEDULA)	

	RETURN SCOPE_IDENTITY()

	END
-----------------------------------------------------
	--ACTUALIZAR
-----------------------------------------------------	
	IF @OPERACION = 1
	BEGIN
		
		UPDATE USUARIOS
		SET
			NUMERO_CEDULA = @NUMERO_CEDULA,
			NOMBRE			= @NOMBRE,
			PRIMER_APELLIDO = @PRIMER_APELLIDO,
			SEGUNDO_APELLIDO = @SEGUNDO_APELLIDO,			
			[PASSWORD]  = @PASSWORD 
		WHERE Id = @ID
	END
-----------------------------------------------------
	--ELIMINAR
-----------------------------------------------------
	IF @OPERACION = 2
	BEGIN
		
		DELETE USUARIOS WHERE ID <> 1 -- USUARIO POR DEFECTO
		AND Id = @ID 
	END

-----------------------------------------------------
	--CONSULTAR UNO POR USUARIO
-----------------------------------------------------

	IF @OPERACION = 3
	BEGIN

	SELECT 
		USUARIOS.Id,
		Numero_Cedula,
		USUARIOS.Nombre,
		Primer_Apellido,
		ISNULL(Segundo_Apellido,'') Segundo_Apellido,
		USUARIOS.USER_NAME AS UserName,
		USUARIOS.PASSWORD AS Password		
	FROM USUARIOS	
	WHERE USUARIOS.USER_NAME = @USER_NAME	

	END
-----------------------------------------------------
	--CONSULTAR TODOS
-----------------------------------------------------	
	IF @OPERACION = 4
	BEGIN

	SELECT 
		USUARIOS.Id,
		Numero_Cedula,
		USUARIOS.Nombre,
		Primer_Apellido,
		ISNULL(Segundo_Apellido,'') Segundo_Apellido,		
		USUARIOS.USER_NAME AS UserName,
		USUARIOS.PASSWORD AS Password
	FROM USUARIOS			

	END
-----------------------------------------------------
	--CONSULTA EXISTE USUARIO
-----------------------------------------------------	
	IF @OPERACION = 5
	BEGIN
		SELECT  
			Id		
		FROM USUARIOS
		WHERE
			USUARIOS.USER_NAME = @USER_NAME
	END

END
