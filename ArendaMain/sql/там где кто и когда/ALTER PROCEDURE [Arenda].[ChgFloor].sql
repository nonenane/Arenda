USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[ChgFloor]    Script Date: 16.12.2020 15:49:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [Arenda].[ChgFloor]
	@id int,
	@cname varchar(15),
	@abbreviation varchar(10),
	@isActive bit,@id_user int = null
As
Begin
	Update Arenda.s_Floors
	Set	
		cName = @cname, Abbreviation = @abbreviation, isActive = @isActive,id_Editor = @id_user,DateEdit = GETDATE()

	Where		
		id = @id

End