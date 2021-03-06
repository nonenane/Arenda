USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[CheckBankName]    Script Date: 28.01.2021 11:54:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Autor:		Molotkova_IS
-- Create date:	12-02-2020
-- Descriprion:	Проверка наличия банка с таким же именем
-- =============================================
ALTER PROCEDURE [Arenda].[CheckBankName]
	@id INT,
	@cName VARCHAR(MAX)

AS
BEGIN
SET NOCOUNT ON
	SELECT
		id,
		cName,
		CorrespondentAccount,
		BIC,
		isActive
	FROM [Arenda].[s_Banks]
	WHERE LOWER(RTRIM(LTRIM(cName))) = LOWER(RTRIM(LTRIM(@cName))) AND id != @id
END
