USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[CheckObjectName]    Script Date: 28.01.2021 12:41:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Autor:		Molotkova_IS
-- Create date:	28-11-2019
-- Descriprion:	Проверка наличия объекта аренды с таким же именем
-- =============================================
ALTER PROCEDURE [Arenda].[CheckObjectName]
	@id INT,
	@cName VARCHAR(MAX)

AS
BEGIN
SET NOCOUNT ON
	SELECT
		id,
		cName,
		isActive,
		o.CadastralNumber,
		o.Comment
	FROM [Arenda].[s_ObjectLease] o
	WHERE LOWER(RTRIM(LTRIM(cName))) = LOWER(RTRIM(LTRIM(@cName))) AND id != @id
END
