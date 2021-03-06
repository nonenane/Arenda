USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[GetListDoc]    Script Date: 02.03.2021 14:07:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Editor:		Molotkova_IS
-- Edit date:	02-12-2019, 29-01-2020
-- Description:	Добавлены поля id_ObjectLease, ObjName; В id_lord подается только id без доп. информации
-- update:		kav 26-08-2020 здание поменял на участок для земельной аренды, 04-09-2020 isActive для расторгнутых
-- =============================================
ALTER PROCEDURE [Arenda].[GetListDoc]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

select 
	id_Agreements 
INTO
	#tmpActCancel
from 
	[Arenda].[j_AdditionalDocuments] where id_TypeDoc = 3 and isActive = 1 group by id_Agreements

select 
	id_Doc as id_Agreements 
INTO
	#tmpActs
from 
	--[Arenda].[j_AdditionalDocuments] group by id_Agreements
	[Arenda].[j_Scan] group by id_Doc

DECLARE @day int = 0
	select @day = value from dbo.prog_config where id_prog = 249  and id_value = 'SRZA'

Select
	A.id,
	A.Date_of_Conclusion as Дата,
	(o.Abbreviation + ' ' + lt.cName ) AS Арендатор,
	A.Agreement AS '№',
	A.Start_Date AS Начало,
	A.Stop_Date AS Конец,
	case 
		when B.Abbreviation is not null and A.id_TypeContract = 1 then 'здание ' + B.Abbreviation + ' ' + F.Abbreviation + ' этаж, секция №:' + S.cName
		when B.Abbreviation is not null and A.id_TypeContract = 2 then 'здание ' + B.Abbreviation + ', Номер: ' + RP.NumberPlace
		when LP.NumberPlot is not null and A.id_TypeContract = 3 then 'участок ' + LP.NumberPlot
		when B.Abbreviation is not null and A.id_TypeContract = 1002 then 'здание ' + B.Abbreviation + ', Номер: ' + RP.NumberPlace+isnull(' возле секции: ' +ad.NumSection,'')
		WHEN B.Abbreviation is null THEN ''
	end AS Место,
	A.Total_Area AS S,
	A.Total_Sum AS Аренда,
	A.Phone AS Тел,
	/*(select o1.Abbreviation  +' ' + lt1.cName 
	from Arenda2.s_Landlord_Tenant lt1 
	left join Arenda2.s_Type_of_Organization o1 on  lt1.id_Type_Of_Organization = o1.id
	where lt1.id = A.id_Landlord ) AS id_lord,*/
	A.id_Landlord AS id_lord,
	A.id_ObjectLease,
	ob.cName as ObjName,
	A.id_TypeContract,
	tc.TypeContract,
	A.isConfirmed,
	cast(case when ac.id_Agreements is null then 0 else 1 end as bit) as isCancelDoc
	,cast(case when DATEADD(day,-@day,A.Stop_Date) < cast(GETDATE() as date) then 1 else 0 end as bit) as isEndingDoc
	,cast(case when A.Stop_Date < cast(GETDATE() as date) then 1 else 0 end as bit) as isDocForLostTime
	,cast(case when ats.id_Agreements is null then 1 else 0 end as bit) as isUseDopData
	,cast(case when scn.id is not null then 1 else 0 end as bit) as isActUse
	,A.fullPayed
from Arenda.j_Agreements A
left join Arenda.s_Landlord_Tenant lt on  A.id_Tenant= lt.id
left join Arenda.s_Type_of_Organization o on  lt.id_Type_Of_Organization = o.id
left join Arenda.s_Building B on A.id_Buildings = B.id
left join Arenda.s_Floors F on A.id_Floor = F.id
left join Arenda.s_Sections S on A.id_Section = S.id and A.id_TypeContract = 1
left join Arenda.s_ReclamaPlace RP on A.id_Section = RP.id and A.id_TypeContract in(1002, 2)
left join Arenda.s_LandPlot LP on A.id_Section = LP.id and A.id_TypeContract = 3

left join Arenda.s_ObjectLease ob on A.id_ObjectLease = ob.id
left join Arenda.s_TypeContract tc on A.id_TypeContract = tc.id
left join #tmpActCancel ac on ac.id_Agreements = A.id
left join #tmpActs ats on ats.id_Agreements = A.id
left join Arenda.j_Scan scn on scn.id_Doc = A.id and scn.id_DocType = 2


left join [Arenda].[j_AdditionalAgreements] ad on ad.id_Agreements = A.id
 
DROP TABLE #tmpActCancel,#tmpActs

END

