USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[spg_GetListOwe]    Script Date: 13.11.2020 13:42:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sporykhin G.Y.
-- Create date: 2020-07-27
-- Description:	Получение списка должников
-- =============================================
ALTER PROCEDURE [Arenda].[spg_GetListOwe]
	-- Add the parameters for the stored procedure here
	@id_object int = 0 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	

select id_Agreements,max(DateSeal) as DateSeal INTO #tableDateSeal from 
Arenda.j_SealSections where DateOpen is null
group by id_Agreements

select 
	a.id,
	too.Abbreviation + ' ' + lt.cName as nameTenant,
	a.Agreement,
	ol.cName as nameObjectLease,
	a.id_TypeContract,
	isnull(case 
		when a.id_TypeContract = 1 then isnull(b.cName+', ','')+isnull(f.cName+' ','')+isnull(s.cName,'')
		when a.id_TypeContract = 2 then isnull(b2.cName,'')+', номер рекламного места:'+isnull(rp.NumberPlace,'')
		when a.id_TypeContract = 3 then 'Номер земельного участка:'+isnull(lp.NumberPlot,'')
	end,'') as namePlace,

	isnull(case 
		when a.id_TypeContract = 1 then isnull(b.cName+' ','')
		when a.id_TypeContract = 2 then isnull(b2.cName,'')
		when a.id_TypeContract = 3 then ''
	end,'') as buildName,
	isnull(case 
		when a.id_TypeContract = 1 then isnull(f.cName+' ','')
		when a.id_TypeContract = 2 then ''
		when a.id_TypeContract = 3 then ''
	end,'') as floorName,
	isnull(case 
		when a.id_TypeContract = 1 then isnull(s.cName,'')
		when a.id_TypeContract = 2 then isnull(rp.NumberPlace,'')
		when a.id_TypeContract = 3 then isnull(lp.NumberPlot,'')
	end,'') as sectionName,



	a.Cost_of_Meter,
	a.Total_Sum,
	ds.DateSeal,
	a.id_ObjectLease,
	--a.Start_Date,
	dateadd(day,isnull(aa.RentalVacation,0),isnull(ad.DateDocument,a.Start_Date)) as Start_Date,
	[Arenda].[fGetDateEndAgreements](a.id) as Stop_Date,-- a.Stop_Date,
	a.id_Tenant,
	isnull(a.Phone,0) as Phone
from
	Arenda.j_Agreements a 
		inner join Arenda.s_Landlord_Tenant lt on lt.id = a.id_Tenant
		inner join Arenda.s_Type_of_Organization too on too.id = lt.id_Type_Of_Organization
		inner join Arenda.s_ObjectLease ol on ol.id = a.id_ObjectLease
		left join #tableDateSeal ds on ds.id_Agreements  = a.id


		left join Arenda.s_Building b  on b.id = a.id_Buildings and a.id_TypeContract = 1
		left join Arenda.s_Floors f on f.id = a.id_Floor
		left join Arenda.s_Sections s on s.id = a.id_Section

		left join Arenda.s_ReclamaPlace rp on rp.id = a.id_Section and a.id_TypeContract = 2
		left join Arenda.s_Building b2 on b2.id = rp.id_Building

		left join Arenda.s_LandPlot lp on lp.id = a.id_Section and a.id_TypeContract = 3

		left join Arenda.j_AdditionalDocuments ad on ad.id_Agreements = a.id and ad.id_TypeDoc = (select top(1) id from Arenda.s_TypeDoc where Rus_Name = 'Акт приёма-передачи') and ad.isActive = 1
		left join Arenda.j_AdditionalAgreements aa on aa.id_Agreements = a.id
where 
	a.isConfirmed = 1 and a.fullPayed = 0 and (@id_object = 0 or a.id_ObjectLease = @id_object)
order by a.id_Tenant asc

DROP TABLE #tableDateSeal

END

