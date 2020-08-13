USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[GetPayments]    Script Date: 13.08.2020 10:32:47 ******/
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
	 case 
		when pc.isCash is null then ''
		when pc.isCash = 1 then 'Нал.' else 'Безнал.'
	end as typeCash,
	case 
		when pc.isToTenant is null then ''
		when pc.isToTenant = 1 then 'Оплата' else 'Возврат'
	end as typeTenant
	from 
		[Arenda].[j_PaymentContract] pc
			left join Arenda.s_PayType pt on pt.id = pc.id_PayType
		
	where 
		pc.[id_Agreements] = @id_Agreements
	order by pc.[Date]
		
END
