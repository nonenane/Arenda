USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddZdan]    Script Date: 16.12.2020 15:29:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	
-- =============================================
ALTER PROCEDURE [Arenda].[AddZdan] 
@cname varchar(30),
@abbreviation varchar(10),
@isActive bit = 1 ,@id_user int = null
AS
BEGIN
SET NOCOUNT ON
	INSERT INTO [Arenda].[s_Building]
           ([cName],[Abbreviation],[isActive],id_Creator,id_Editor,DateCreate,DateEdit)
     VALUES
           (@cname
           ,@abbreviation 
           ,@isActive,@id_user,@id_user,GETDATE(),GETDATE())
end