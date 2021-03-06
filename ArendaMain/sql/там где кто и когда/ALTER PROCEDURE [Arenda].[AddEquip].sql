USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddEquip]    Script Date: 16.12.2020 15:47:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			Cvetkov K.
-- Create date:		unknown
-- Description:		Процедура добавления оборудования
-- Modified by:		Butakov I.A.
-- Modify date:		30-01-2015
-- Modification:	Возвращаем id добавленной записи
-- =============================================
ALTER PROCEDURE [Arenda].[AddEquip] 
@cname varchar(150),
@abbreviation varchar(10),
@isActive bit =1 ,@id_user int = null

AS
BEGIN
SET NOCOUNT ON
	
	INSERT INTO [Arenda].[s_Equipment]
           ([cName],[Abbreviation],[isActive],id_Creator,id_Editor,DateCreate,DateEdit
)
     VALUES
           (@cname
           ,@abbreviation 
           ,@isActive,@id_user,@id_user,GETDATE(),GETDATE()
)
           
	select SCOPE_IDENTITY();
end
