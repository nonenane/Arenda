USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[spg_setConfirmedTaxes]    Script Date: 01.02.2021 15:35:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sporykhin G.Y.
-- Create date: 2020-07-27
-- Description:	Подтверждение доп оплаты контролёром
-- =============================================
ALTER PROCEDURE [Arenda].[spg_setConfirmedTaxes]		
	@id int,
	@id_user int,
	@isConfirmed bit = 1
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY
	UPDATE 
		Arenda.[j_Fines]
	SET
		isConfirmed = @isConfirmed,
		id_Editor = @id_user,
		DateEdit = GETDATE()
	WHERE
		id = @id

	select @id as id
END TRY
BEGIN CATCH
	select -1 as id
END CATCH
	
	
END
