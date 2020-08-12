USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[GetListDoc]    Script Date: 24.07.2020 10:49:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sporykhin G.Y.
-- Create date: 2020-07-27
-- Description:	��������� ������ ����� �� ��������
-- =============================================
CREATE PROCEDURE [Arenda].[spg_GetPaymentsForAgreemetns]
	@id_Agreements int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select 
		p.Summa
	from 
		Arenda.j_PaymentContract p
	where 
		id_Agreements = @id_Agreements

END
