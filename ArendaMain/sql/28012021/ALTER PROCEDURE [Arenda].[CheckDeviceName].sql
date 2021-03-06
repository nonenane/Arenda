USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[CheckDeviceName]    Script Date: 28.01.2021 12:31:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Autor:		Molotkova_IS
-- Create date:	27-02-2020
-- Descriprion:	Проверка наличия прибора с таким же именем
-- =============================================
ALTER PROCEDURE [Arenda].[CheckDeviceName]
	@id INT,
	@cName VARCHAR(MAX)

AS
BEGIN
SET NOCOUNT ON
	SELECT
		id,
		cName,
		isActive,
		d.Abbreviation,
		d.Unit
	FROM [Arenda].[s_Device] d
	WHERE LOWER(RTRIM(LTRIM(cName))) = LOWER(RTRIM(LTRIM(@cName))) AND id != @id
END
