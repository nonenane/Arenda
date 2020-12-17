USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[ChgTypePr]    Script Date: 16.12.2020 16:04:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [Arenda].[ChgTypePr]
	@id int,
	@cname varchar(100),
	@isActive bit,@id_user int = null
As
Begin
	Update Arenda.s_Type_of_Premises
	Set	
		cName = @cname, isActive = @isActive,id_Editor = @id_user,DateEdit = GETDATE()
	Where		
		id = @id

End