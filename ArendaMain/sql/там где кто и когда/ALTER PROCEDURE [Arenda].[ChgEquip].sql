USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[ChgEquip]    Script Date: 16.12.2020 15:47:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [Arenda].[ChgEquip]
	@id int,
	@cname varchar(150),
	@abbreviation varchar(10),
	@isActive bit,@id_user int = null

As
Begin
	Update Arenda.s_Equipment
	Set	
		cName = @cname, Abbreviation = @abbreviation, isActive = @isActive,id_Editor = @id_user,DateEdit = GETDATE()

	Where		
		id = @id

End
