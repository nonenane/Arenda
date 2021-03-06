USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[spg_getTDiscount]    Script Date: 01.02.2021 10:18:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sporykhin G.Y.
-- Create date: 2020-06-23
-- Description:	Получение списка скидок по договору
-- update:		kav 2020-09-04 поле для выбора в чекбоксе
-- =============================================
ALTER PROCEDURE [Arenda].[spg_getTDiscount]		 
	@id_Agreements int = -1
AS
BEGIN
	SET NOCOUNT ON;

IF @id_Agreements <> - 1
	BEGIN
		select 
			d.id,
			d.DateStart,
			d.DateEnd, 
			d.id_TypeDiscount,
			d.id_StatusDiscount,
			td.cName as nameTypeDiscount,
			d.Discount,
			sd.cName as nameStatusDiscount
		from 
			[Arenda].[j_tDiscount] d
				left join Arenda.s_TypeDiscount td on td.id = d.id_TypeDiscount
				left join Arenda.s_StatusDiscount sd on sd.id = d.id_StatusDiscount
		where 
			id_Agreements = @id_Agreements
	END
ELSE
	BEGIN
		select
			d.id,
			d.DateStart,
			d.DateEnd, 
			d.id_TypeDiscount,
			d.id_StatusDiscount,
			td.cName as nameTypeDiscount,
			d.Discount,
			sd.cName as nameStatusDiscount,
			a.id_ObjectLease,
			ol.cName as nameObjectLease,
			type_org.Abbreviation + ' ' + lt.cName as nameLandLord,
			a.Agreement,
			a.id_TypeContract,
			tc.TypeContract,
			d.id_Agreements,
			cast(0 as bit) as selected,
			a.id_Tenant
			
		from 
			[Arenda].[j_tDiscount] d
				left join Arenda.s_TypeDiscount td on td.id = d.id_TypeDiscount
				left join Arenda.s_StatusDiscount sd on sd.id = d.id_StatusDiscount
				left join Arenda.j_Agreements a on a.id = d.id_Agreements
				left join Arenda.s_TypeContract tc on tc.id = a.id_TypeContract
				left join Arenda.s_ObjectLease ol on ol.id = a.id_ObjectLease
				left join Arenda.s_Landlord_Tenant lt on lt.id = a.id_Tenant
				left join Arenda.s_Type_of_Organization type_org on type_org.id = lt.id_Type_Of_Organization
	END
END
