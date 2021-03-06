USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddFloor]    Script Date: 16.12.2020 15:50:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [Arenda].[AddFloor]
	@cname varchar(20),
	@abbr varchar(10),
	@isActive bit =1 ,@id_user int = null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO [Arenda].[s_Floors]
	([cName],[Abbreviation],[isActive],id_Creator,id_Editor,DateCreate,DateEdit
)
     VALUES
           (@cname
           ,@abbr 
           ,@isActive,@id_user,@id_user,GETDATE(),GETDATE()
)
END