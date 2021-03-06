USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[spg_GetListOweAdditionalData]    Script Date: 13.11.2020 13:42:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sporykhin G.Y.
-- Create date: 2020-07-27
-- Description:	Получение дополнительной информации для должников
-- =============================================
ALTER PROCEDURE [Arenda].[spg_GetListOweAdditionalData]
	@typeData int,
	@id_object int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @typeData = 1
		BEGIN
			--select 
			--	d.id_Agreements,
			--	d.DateStart,
			--	d.DateEnd,
			--	d.id_TypeDiscount,
			--	d.Discount,
			--	a.Total_Sum,
			--	a.Total_Area,
			--	a.Start_Date,
			--	a.Stop_Date
			--from 
			--	Arenda.j_tDiscount d
			--		inner join Arenda.j_Agreements a on a.id = d.id_Agreements
			--where 
			--	a.isConfirmed = 1 
			--	--and a.id = 1053 
			--	and d.id_StatusDiscount = 2
			--order by 
			--	d.DateStart asc

			select 
				a.id as id_Agreements,
				d.DateStart,
				d.DateEnd,
				d.id_TypeDiscount,
				d.Discount,
				a.Total_Sum,
				a.Total_Area,
				dateadd(day,isnull(aa.RentalVacation,0),isnull(ad.DateDocument,a.Start_Date)) as Start_Date,
				[Arenda].[fGetDateEndAgreements](a.id) as Stop_Date,-- a.Stop_Date,
				d.id as id_discount
			from 
				Arenda.j_Agreements a 
					left join Arenda.j_tDiscount d on d.id_Agreements =  a.id and d.id_StatusDiscount = 2
					left join Arenda.j_AdditionalDocuments ad on ad.id_Agreements = a.id and ad.id_TypeDoc = (select top(1) id from Arenda.s_TypeDoc where Rus_Name = 'Акт приёма-передачи')
					left join Arenda.j_AdditionalAgreements aa on aa.id_Agreements = a.id
			where 
				a.isConfirmed = 1  and a.fullPayed = 0  and (@id_object = 0 or a.id_ObjectLease = @id_object)
				--and a.id = 1053 
				--and d.id_StatusDiscount = 2
			order by 
				d.DateStart asc
		END
	ELSE
		BEGIN		
			--select 
			--	a.id,
			--	a.Summa as SummaPaymentFine,
			--	a.sumPay as SummaFine,
			--	a.Summa - a.sumPay as SummaPenny,
			--	case when a.Summa = 0 then 0.0 else  round(((a.Summa - a.sumPay)/a.Summa)*100,2) end as PrcPenny,
			--	a.cName
			--from (
			----select 
			----	a.id,f.Summa,cast(0 as numeric (16,2)) as sumPay,ad.cName							
			----from	
			----	Arenda.j_Agreements a
			----		inner join Arenda.j_Fines f on f.id_Agreements = a.id
			----		inner join Arenda.s_AddPayment ad on ad.id = f.id_АddPayment
			----		--left join Arenda.s_PayType t on t.id = 
			----where 
			----	a.isConfirmed = 1 and ad.isActive = 1 
			----	--and a.fullPayed = 0  
			----	and (@id_object = 0 or a.id_ObjectLease = @id_object)

			----UNION ALL

			--select a.id,cast(f.Summa as numeric (16,2)) as Summa,sum(isnull(pc.Summa,0.0))  as sumPay,ad.cName
			--from Arenda.j_Agreements a 
			--		inner join Arenda.j_Fines f on f.id_Agreements = a.id
			--		inner join Arenda.s_AddPayment ad on ad.id = f.id_АddPayment
			--		left join Arenda.j_PaymentContract pc on pc.id_Fines = f.id					
			--where 
			--	a.isConfirmed = 1  and ad.isActive = 1 
			--	--and a.fullPayed = 0  
			--	and (@id_object = 0 or a.id_ObjectLease = @id_object)
			--group by a.id,f.id,f.Summa,ad.cName,f.id_АddPayment
			--) as a
			--order by a.id asc
			----GROUP BY 
			----	a.id

			
			select 
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
				Z.id,
				Z.Summa as SummaPaymentFine_2,
				Z.sumPay as SummaFine_2,
				Z.Summa - Z.sumPay as SummaPenny_2,
				case when Z.Summa = 0 then 0.0 else  round(((Z.Summa - Z.sumPay)/Z.Summa)*100,2) end as PrcPenny_2,
				Z.cName as NameAddPayment,
				a.id_ObjectLease,
				a.id_Tenant,
				Z.id_АddPayment
			from
				(select a.id,
				cast(f.Summa as numeric (16,2)) as Summa,
				sum(isnull(pc.Summa,0.0))  as sumPay,
				ad.cName,
				f.id_АddPayment
			from Arenda.j_Agreements a 
					inner join Arenda.j_Fines f on f.id_Agreements = a.id
					inner join Arenda.s_AddPayment ad on ad.id = f.id_АddPayment
					left join Arenda.j_PaymentContract pc on pc.id_Fines = f.id					
			where 
				a.isConfirmed = 1  and ad.isActive = 1 
				--and a.fullPayed = 0  
				and (@id_object = 0 or a.id_ObjectLease = @id_object)
			group by a.id,f.id,f.Summa,ad.cName,f.id_АddPayment
			) as Z			
			left join Arenda.j_Agreements a on a.id = Z.id
			inner join Arenda.s_Landlord_Tenant lt on lt.id = a.id_Tenant
			inner join Arenda.s_Type_of_Organization too on too.id = lt.id_Type_Of_Organization
			inner join Arenda.s_ObjectLease ol on ol.id = a.id_ObjectLease

			left join Arenda.s_Building b  on b.id = a.id_Buildings and a.id_TypeContract = 1
			left join Arenda.s_Floors f on f.id = a.id_Floor
			left join Arenda.s_Sections s on s.id = a.id_Section

			left join Arenda.s_ReclamaPlace rp on rp.id = a.id_Section and a.id_TypeContract = 2
			left join Arenda.s_Building b2 on b2.id = rp.id_Building

			left join Arenda.s_LandPlot lp on lp.id = a.id_Section and a.id_TypeContract = 3			

		END



END

