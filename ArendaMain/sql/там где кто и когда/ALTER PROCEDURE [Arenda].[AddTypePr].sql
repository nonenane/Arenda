USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddTypePr]    Script Date: 16.12.2020 16:04:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [Arenda].[AddTypePr]
	-- Add the parameters for the stored procedure here
	@cname varchar(100),
	@isActive bit = 1 ,@id_user int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [Arenda].[s_Type_of_Premises]
	([cName],[isActive],id_Creator,id_Editor,DateCreate,DateEdit)
     VALUES
           (@cname
           ,@isActive,@id_user,@id_user,GETDATE(),GETDATE())
END