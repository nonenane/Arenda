USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[ChgZdan]    Script Date: 16.12.2020 15:29:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [Arenda].[ChgZdan]
	@id int,
	@cname varchar(15),
	@abbreviation varchar(10),
	@isActive bit,@id_user int = null
As
Begin
	Update Arenda.s_Building
	Set	
		cName = @cname, Abbreviation = @abbreviation, isActive = @isActive
,id_Editor = @id_user,DateEdit = GETDATE()
	Where		
		id = @id

End