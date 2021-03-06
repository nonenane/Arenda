USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[setScan]    Script Date: 20.01.2021 11:49:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Molotkova_IS
-- Create date: 2019-03-22
-- Description:	Запись сканов
-- Editor:		Molotkova_IS
-- Edit date:	2019-12-15
-- Description: Добавлено поле Path
-- =============================================
ALTER PROCEDURE [Arenda].[setScan]
	@id_Doc int,
	@nameFile varchar(max),
	@idUser int,
	@Extension varchar(50),
	@id_DocType int,
	@DateDocument date,
	@Path varchar(max)
	
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	if not exists(select * from [Arenda].j_Scan where id_Doc = @id_Doc and cName = @nameFile and id_DocType = @id_DocType and Extension = @Extension)
	begin
		INSERT INTO 
			[Arenda].j_Scan(id_Doc, cName, Scan, DateInsert, id_Insert, Extension, id_DocType, DateDocument, [Path])
		VALUES
			(@id_Doc, @nameFile, null, GETDATE(), @idUser, @Extension, @id_DocType, @DateDocument,@Path)

		SELECT cast(SCOPE_IDENTITY() as int) as id
	end
	else 
	begin
		UPDATE 
			[Arenda].j_Scan 
		set 
			DateInsert= GETDATE(),id_Insert = @idUser 
		where 
			id_Doc = @id_Doc and cName = @nameFile and id_DocType = @id_DocType and Extension = @Extension

		select TOP(1) id from [Arenda].j_Scan where id_Doc = @id_Doc and cName = @nameFile and id_DocType = @id_DocType and Extension = @Extension
	end

END
