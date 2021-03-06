USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[GetPayments]    Script Date: 20.11.2020 14:40:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Butakov I.
-- Create date: 14-11-2014
-- Description:	Получение списка оплат по договору
-- Modified:    18-03-2015
-- ModifiedBy:  Butakov I.
-- Description:	Удалено поле isPayment
-- update:		kav 2020-08-28 isToTenant возврат и оплата неправильно приходили
-- update:		kav 2020-09-10 isToTenant поле not null и выгружаем для подсчета суммы
-- =============================================
ALTER PROCEDURE [Arenda].[GetPayments]	
	@id_Agreements int	
AS
BEGIN
	
	--0 -- аренда 
	--1 -- телефон
	--2 -- реклама
	declare @isPayment int = 0
	 

	if (select isnull(agr.Reklama,0) from Arenda.j_Agreements agr where agr.id = @id_Agreements)>0
	begin
		set @isPayment = 2		
	end
	else
	begin
		set @isPayment = 0
	end
	
	select 
	   pc.[id]
	  ,pc.[id_Agreements]
	  ,pc.[Date] as PaymentDate
	  ,Convert(varchar(max),pc.[Summa]) as PaymentSum
	  ,@isPayment as isPayment
	  ,pc.[DateEdit]
	  ,pc.[id_Editor]
	  ,isnull(
	  (select ltrim(rtrim(FIO)) from ListUsers where id = pc.id_Editor),'') as Editor
	  ,case 
			when @isPayment = 0 then 'аренда'
			when @isPayment = 1 then 'телефон'
			else 'реклама'
	   end
	   as [sign],
	   pt.cName as namePaymentType,
	   pc.id_PayType,
	 case 
		when pc.isCash is null then ''
		when pc.isCash = 1 then 'Нал.' else 'Безнал.'
	end as typeCash,
	case 
		when pc.isToTenant is null then ''
		when pc.isToTenant = 1 then 'Возврат' else 'Оплата'
	end as typeTenant
	, pc.isToTenant
	,cast(pc.PlaneDate as date) as planedate
	--поля для того, где есть ссылка на j_Fines
	,ap.cName as fTypePayment
	,f.Summa as fSumma
	,f.PlanDate as fMonth
	,cast(f.DateFines as date) as fDateCreate,
	pc.Description
	from 
		[Arenda].[j_PaymentContract] pc
			left join Arenda.s_PayType pt on pt.id = pc.id_PayType
			left join Arenda.j_Fines f on pc.id_Fines =f.id  
			left join Arenda.s_AddPayment ap on f.id_АddPayment = ap.id
	where 
		pc.[id_Agreements] = @id_Agreements
	order by pc.[Date]
		
END
