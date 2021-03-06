USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddEditEqVsSec]    Script Date: 16.12.2020 15:20:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	0 - редактирование , 1 - добавление 
-- =============================================

ALTER PROCEDURE [Arenda].[AddEditEqVsSec]
	-- Add the parameters for the stored procedure here
	@Sec int,
	@Eq int,
	@Count numeric(6),
	@mode int,
	@id int
	,@id_user int = null
AS
BEGIN
	SET NOCOUNT ON;

	if @mode = 1 
	Begin 	
		INSERT INTO [Arenda].[Equipment_vs_Sections]
			   ([id_Equipment],[id_Sections],[Quantity],id_Creator,id_Editor,DateCreate,DateEdit)
		 VALUES
			   (@Eq
			   ,@Sec
			   ,@Count,@id_user,@id_user,GETDATE(),GETDATE())
		
		select SCOPE_IDENTITY()
	End
	
	if @mode = 0 
	begin
		Update Arenda.Equipment_vs_Sections
		Set	
			id_Equipment = @Eq, 
			id_Sections = @Sec,
			Quantity = @Count,id_Editor = @id_user,DateEdit = GETDATE()
		Where		
			id = @id
			
		select @id
	end
END
