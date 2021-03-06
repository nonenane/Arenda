USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[spg_GetListTaxesForKnt]    Script Date: 01.02.2021 11:10:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sporykhin G Y
-- Create date: 2020-07-29
-- Description:	Получение списка доп оплат для КНТ
-- =============================================
ALTER PROCEDURE [Arenda].[spg_GetListTaxesForKnt]
	@DatePlane date
AS
BEGIN


select 
	jf.id,
	a.Agreement,
	jf.DateFines,
	sad.cName,
	jf.Summa,
	isnull(jf.isConfirmed,0) as isConfirmed,
	cast(0 as bit) as isSelect,
	a.id_ObjectLease,
	ob.cName as nameObject,
	too.Abbreviation + ' ' + lt.cName as nameTenant,
	jf.Comment,
	jf.id_АddPayment,
	jf.id_Agreements

from 
	[Arenda].[j_Fines] jf
		left join [Arenda].s_AddPayment sad on jf.id_АddPayment = sad.id 
		left join Arenda.j_Agreements a on a.id = jf.id_Agreements
		left join Arenda.s_ObjectLease ob on ob.id = a.id_ObjectLease

		inner join Arenda.s_Landlord_Tenant lt on lt.id = a.id_Tenant
		inner join Arenda.s_Type_of_Organization too on too.id = lt.id_Type_Of_Organization

where
	jf.PlanDate = @DatePlane
order by 
	jf.id_Agreements asc
	
		
END
