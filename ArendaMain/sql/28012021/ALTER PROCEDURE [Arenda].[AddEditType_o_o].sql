USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddEditType_o_o]    Script Date: 28.01.2021 11:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> 1 - добавить , 0- изменить
-- =============================================
ALTER PROCEDURE [Arenda].[AddEditType_o_o]
	-- Add the parameters for the stored procedure here
	@cName varchar(300),
	@abbr varchar (20),
	@id int,
	@mode int,
	@isActive int
	,@id_user int = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
if @mode = 1
begin
	insert into Arenda.s_Type_of_Organization ([cName],[Abbreviation],[isActive],id_Creator,id_Editor,DateCreate,DateEdit )
	Values (@cName, @abbr,1,@id_user,@id_user,GETDATE(),GETDATE())

	select cast(SCOPE_IDENTITY() as int) as id

end 

if @mode = 0
begin
Update Arenda.s_Type_of_Organization
	Set cName = @cName, 
	Abbreviation = @abbr,
	isActive = @isActive,id_Editor = @id_user,DateEdit = GETDATE()
	where id = @id

	select @id as id 
end

    
END
