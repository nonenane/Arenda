USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[SaveDevice]    Script Date: 28.01.2021 12:23:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Korshkova N.>
-- Create date: <24.11.2016>
-- Description:	<Сохраняет запись о приборе.>
-- =============================================
ALTER PROCEDURE [Arenda].[SaveDevice]
	@id int,
	@name varchar(64),
	@abbreviation varchar(64),
	@unit varchar(64),@id_user int = null

AS
BEGIN
	SET NOCOUNT ON;

    if @id = 0
    begin
    
		insert into Arenda.s_Device (cName, Abbreviation, Unit, isActive,id_Creator,id_Editor,DateCreate,DateEdit
)
		values (@name, @abbreviation, @unit, 1,@id_user,@id_user,GETDATE(),GETDATE()
)
		
		set @id = cast(SCOPE_IDENTITY() as int)
    end
    else
    begin
    
		update Arenda.s_Device
		set cName = @name,
			Abbreviation = @abbreviation,
			Unit = @unit,id_Editor = @id_user,DateEdit = GETDATE()

		where
			id = @id
			
    end

	select @id as id
	
END
