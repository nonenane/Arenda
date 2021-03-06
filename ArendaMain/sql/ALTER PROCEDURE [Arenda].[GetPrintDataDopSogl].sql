USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[GetPrintDataDopSogl]    Script Date: 16.12.2020 12:16:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Korshkova N.>
-- Create date: <01.12.2016>
-- Description:	<Получает данные для выгрузки доп. соглашения.>
-- Editor:		<Molotkova_IS>
-- Edit date:	<09.01.2020>
-- Description:	<поле ORGNIP переименовано в OGRN>
-- =============================================
ALTER PROCEDURE [Arenda].[GetPrintDataDopSogl]
	@id int,
	@id_dopsogl int
AS
BEGIN
	SET NOCOUNT ON;

    select
			rtrim(ltrim(a.Agreement)) as num_dog,
			Arenda.ConvertDateToString(a.Date_of_Conclusion) as date_dog,
			Arenda.ConvertDateToString(ad.DateDocument) as date_dop,
			rtrim(ltrim(tl.cName + ' ' + l.cName)) as arendodatel,
			rtrim(ltrim(tt.cName + ' ' + t.cName)) as arendator,
			pl.cName + ' ' + l.Contact_Lastname_Par + ' ' + substring(l.Contact_Firstname, 1, 1) + '. ' + substring(l.Contact_Middlename, 1, 1) + '.' as predstavitel,
			t.Contact_Lastname_Par + ' ' + substring(t.Contact_Firstname, 1, 1) + '. ' + substring(t.Contact_Middlename, 1, 1) + '.' as predst_arend,
			b.cName + isnull(' ' + l.Number_basement, '') + case when b.needDate = 1 then isnull(' от ' + Arenda.ConvertDateToString(l.Date_basement), '') else '' end as osnovanie_arendodatel,
			bt.cName + isnull(' ' + other.OGRN, '') + case when bt.needDate = 1 then isnull(' от ' + Arenda.ConvertDateToString(t.Date_basement), '') else '' end as osnovanie_arendator,
			case when other.Sex = 0 then 'его' else 'ей' end as okonchanie_1,
			case when l.Sex = 0 then 'его' else 'ей' end as okonchanie_a,
			
			
			rtrim(ltrim(tl.Abbreviation + ' ' + l.cName)) as name_1,
			rtrim(ltrim(tt.Abbreviation + ' ' + t.cName)) as name_2,
			rtrim(ltrim(l.Address)) as address_1,
			rtrim(ltrim(t.Address)) as address_2,
			other.OGRN as orgnip,
			lanTenBank.PaymentAccount as rs_1,
			TenBank.PaymentAccount as rs_2,
			l.INN as inn_1,
			t.INN as inn_2,
			isnull(rtrim(ltrim(bnl.cName)), '') as bank,
			isnull(bnl.BIC, '') as bik_1,
			isnull(bnt.BIC, '') as bik_2,
			isnull(bnl.CorrespondentAccount, '') as ks_1,
			isnull(bnt.CorrespondentAccount, '') as ks_2,
			l.KPP as kpp_1,
			l.Contact_Lastname + ' ' + substring(l.Contact_Firstname, 1, 1) + '. ' + substring(l.Contact_Middlename, 1, 1) + '.' as predst_1,
			t.Contact_Lastname + ' ' + substring(t.Contact_Firstname, 1, 1) + '. ' + substring(t.Contact_Middlename, 1, 1) + '.' as predst_2,
			other.Passport + ' выдан ' + CONVERT(varchar(10), other.DateIssue, 120) + ' ' + other.Issued as passport,
			l.Mobile_phone as tel_mail_1,
			t.Mobile_phone as tel_mail_2
    from
			Arenda.j_Agreements a  
								   join Arenda.j_AdditionalDocuments ad on a.id = ad.id_Agreements
								   join Arenda.s_Landlord_Tenant l on a.id_Landlord = l.id
			                       join Arenda.s_Type_of_Organization tl on l.id_Type_Of_Organization = tl.id
			                       join Arenda.s_Posts pl on l.id_Posts = pl.id 

			                       join Arenda.s_Landlord_Tenant t on a.id_Tenant = t.id
			                       join Arenda.s_Type_of_Organization tt on t.id_Type_Of_Organization = tt.id
			                       left join Arenda.s_Basement b on l.id_Basement = b.id
			                       left join Arenda.s_Basement bt on t.id_Basement = bt.id
			                       join Arenda.other_Landlord_Tenant other on other.id_Landlord_Tenant = t.id
			                       
								   left join Arenda.[j_AgreementsBank] agrBank on agrBank.id_Agreements = a.id
								   left join Arenda.[s_LandlordTenantBank] lanTenBank on lanTenBank.id = agrBank.id_LandlordTenantBank
								   left join Arenda.s_Banks bnl on bnl.id = lanTenBank.id_Bank

								   left join Arenda.[s_LandlordTenantBank] TenBank on TenBank.id_LandlordTenant = a.id_Tenant
								   left join Arenda.s_Banks bnt on bnt.id = TenBank.id_Bank

			                       --left join Arenda.s_Banks bnl on l.id_Bank = bnl.id
			                       --left join Arenda.s_Banks bnt on t.id_Bank = bnt.id
    where
			a.id = @id and
			ad.id = @id_dopsogl and
			ad.isActive = 1
    
END
