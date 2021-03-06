USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddEditBank]    Script Date: 16.12.2020 15:25:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> 1 - добавить , 0- изменить
-- =============================================
ALTER PROCEDURE [Arenda].[AddEditBank]
	-- Add the parameters for the stored procedure here
	@id int,
	@cName varchar(100),
	@ca varchar (21),
	@bik varchar (9),
	@mode int,
	@isActive int,@id_user int = null

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if @mode = 1
begin
	insert into Arenda.s_Banks([cName],[CorrespondentAccount],[BIC],[isActive]
,id_Creator,id_Editor,DateCreate,DateEdit) 
	Values (@cName, @ca, @bik ,1,@id_user,@id_user,GETDATE(),GETDATE())
end 

if @mode = 0
begin
Update Arenda.s_Banks
	Set cName = @cName, 
	CorrespondentAccount = @ca,
	BIC = @bik,
	isActive = @isActive,id_Editor = @id_user,DateEdit = GETDATE()
	where id = @id
end

    
END
