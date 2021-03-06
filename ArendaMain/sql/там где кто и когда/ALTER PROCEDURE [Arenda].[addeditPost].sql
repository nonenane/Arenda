USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[addeditPost]    Script Date: 16.12.2020 15:57:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Kirill Cvetkov>
-- Create date: <Unknown>
-- Description:	<Добавление/редактирование должностей>
-- Modified by: <Butakov I.A.>
-- Midify date: <2013-11-02>
-- Description:	<Добавлено поле Dative_case>
-- =============================================
ALTER PROCEDURE [Arenda].[addeditPost]
	@id int,
	@cName varchar(300),	
	@isActive int,
	@Dative_case varchar(300),@id_user int = null
AS
BEGIN
	SET NOCOUNT ON;

	if @id = 0
		begin
			insert into [Arenda].[s_Posts]
				([cName],
				[isActive],
				[Dative_case],id_Creator,id_Editor,DateCreate,DateEdit) 
			Values 
				(@cName,  
				@isActive, 
				@Dative_case,@id_user,@id_user,GETDATE(),GETDATE())
		end 
	else
		begin
			Update [Arenda].[s_Posts]
				Set [cName] = @cName, 
				[isActive] = @isActive,
				[Dative_case] = @Dative_case,id_Editor = @id_user,DateEdit = GETDATE()
				where id = @id
		end
		
END
