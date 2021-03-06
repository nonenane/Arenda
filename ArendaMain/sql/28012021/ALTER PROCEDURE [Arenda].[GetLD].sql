USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[GetLD]    Script Date: 28.01.2021 15:31:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Editor:		Molotkova_IS
-- Edit date:	07-12-2019
-- Description:	Добавлены поля id_TypeContract, id_ObjectLease, Obj и CadastralNumber
-- =============================================
ALTER PROCEDURE [Arenda].[GetLD]
	@id int
	AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		a.[id],
		a.[id_Tenant],
		a.[id_Landlord],
		a.[Agreement],
		a.[Date_of_Conclusion],
		a.[Start_Date],
		a.[Stop_Date],
		a.[id_Buildings],
		a.[id_Floor],
		a.[id_Section],
		a.[id_Type_of_Premises],
		a.[Total_Area],
		isnull(a.[Area_of_Trading_Hall], 0) as Area_of_Trading_Hall,
		a.[Cost_of_Meter],
		isnull(a.[Phone], 0) as Phone,
		a.[Total_Sum],
		a.[Payment_Type],
		isnull(a.[Remark], '') as Remark,
		isnull(a.[Reklama], 0) as Reklama,
		isnull(( select o.Abbreviation + ' ' + lt.cName from Arenda.s_Landlord_Tenant lt 
		left join Arenda.s_Type_of_Organization o on lt.id_Type_Of_Organization = o.id
		where lt.id = a.id_Landlord), '') as Landlord_name,
		isnull(b.cName,'') as build,
		isnull(f.cName,'') as floo,
		isnull(s.cName,'') as sec,
		isnull(t.cName,'') as tofp,
		isnull(( select o.Abbreviation + ' ' + lt.cName from Arenda.s_Landlord_Tenant lt 
		left join Arenda.s_Type_of_Organization o on lt.id_Type_Of_Organization = o.id
		where lt.id = a.id_Tenant), '') as Tenant_name,
		isnull(rekl.id,0) as ReklId,
		isnull(rekl.Number,0) as ReklNumber,
		isnull(rekl.Length,0) as ReklLength,
		isnull(rekl.Width,0) as ReklWidth,
		isnull(rekl.Area,0) as ReklArea,
		a.fullPayed,
		isnull(a.failComment,'') as failComment,
		a.id_TypeContract,
		a.CadastralNumber,
		a.id_ObjectLease,
		obj.cName as Obj,
		isnull(lt.Path, '') as Path,
		aa.id_SavePayment,
		aa.RentalVacation,
		a.id_TypeActivities,

		lanTenBank.id as id_LandlordTenantBank,
		lanTenBank.id_Bank,
		bank.cName as NameBank,
		bank.BIC,
		bank.CorrespondentAccount,
		lanTenBank.PaymentAccount,
		a.Agreement1C,
		lt.email,
		lt.Work_phone,
		aa.NumSection

	from Arenda.j_Agreements a 
		left join Arenda.s_Building b
			on a.id_Buildings = b.id 
		left join Arenda.s_Floors f 
			on f.id = a.id_Floor
		left join Arenda.s_Sections s 
			on s.id = a.id_Section
		left join Arenda.s_Type_of_Premises t 
			on t.id = a.id_Type_of_Premises
		left join Arenda.j_OptionsAdvert rekl
			on a.id = rekl.id_Agreements
		left join Arenda.s_ObjectLease obj
			on obj.id = a.id_ObjectLease
		left join Arenda.s_Landlord_Tenant lt
			on lt.id = a.id_Landlord
		left join  [Arenda].[j_AdditionalAgreements] aa 
			on aa.id_Agreements = a.id
		left join Arenda.[j_AgreementsBank] agrBank on agrBank.id_Agreements = a.id
		left join Arenda.[s_LandlordTenantBank] lanTenBank on lanTenBank.id = agrBank.id_LandlordTenantBank
		left join Arenda.s_Banks bank on bank.id = lanTenBank.id_Bank
	
	where a.id = @id;
END
