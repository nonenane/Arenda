USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[RemoveDeviceFromSection]    Script Date: 28.01.2021 11:06:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Korshkova N.>
-- Create date: <29.11.2016>
-- Description:	<Удаляет связь секции с прибором.>
-- =============================================
ALTER PROCEDURE [Arenda].[RemoveDeviceFromSection]
	@id_section int,
	@id_device int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @id int

	select @id = id from Arenda.Devices_vs_Sections
    where id_Sections = @id_section and id_Device = @id_device

    delete from Arenda.Devices_vs_Sections
    where id = @id
    

	select @id as id

END
