USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[SaveObject]    Script Date: 28.01.2021 12:36:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Autor:		Molotkova_IS
-- Create date:	28-11-2019
-- Descriprion:	Сохранение объекта аренды
-- =============================================
ALTER PROCEDURE [Arenda].[SaveObject]
	@id INT,
	@cName VARCHAR(MAX),
	@Comment VARCHAR(MAX),
	@id_User INT,
	@CadastralNumber varchar(1024)

AS
BEGIN
SET NOCOUNT ON
	
	IF @id = 0
	BEGIN
		INSERT INTO [Arenda].[s_ObjectLease](cName, Comment, isActive, id_Creator, DateCreate,CadastralNumber)
		VALUES(@cName, @Comment, 1, @id_User, GETDATE(),@CadastralNumber)

							select cast(SCOPE_IDENTITY() as int) as id

	END
	ELSE
	BEGIN
		UPDATE [Arenda].[s_ObjectLease]
		SET cName = @cName,
			Comment = @Comment,
			id_Editor = @id_User,
			DateEdit = GETDATE(),
			CadastralNumber = @CadastralNumber
		WHERE
			id = @id

								select @id as id 

	END
END
