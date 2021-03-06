USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddDeviceToSection]    Script Date: 28.01.2021 10:57:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Korshkova N.>
-- Create date: <29.11.2016>
-- Description:	<Сохраняет связь прибора и секции.>
-- =============================================
ALTER PROCEDURE [Arenda].[AddDeviceToSection]
	@id_section int,
	@id_device int,
	@quantity numeric(6,0),
	@id_user int = null
AS
BEGIN
	SET NOCOUNT ON;

	if exists (select id from Arenda.Devices_vs_Sections where id_Sections = @id_section and id_Device = @id_device)
	begin
		update Arenda.Devices_vs_Sections
		set Quantity = @quantity,id_Editor = @id_user,DateEdit = GETDATE()
		where id_Device = @id_device and id_Sections = @id_section

		select id from Arenda.Devices_vs_Sections where id_Device = @id_device and id_Sections = @id_section
	end
	else
	begin
		insert into Arenda.Devices_vs_Sections (id_Sections, id_Device, Quantity,id_Creator,id_Editor,DateCreate,DateEdit)
		values (@id_section, @id_device, @quantity,@id_user,@id_user,GETDATE(),GETDATE())

		select cast(SCOPE_IDENTITY() as int) as id

    end
    
END
