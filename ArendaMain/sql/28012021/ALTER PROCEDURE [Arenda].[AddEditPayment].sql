USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddEditPayment]    Script Date: 10.02.2021 15:41:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Butakov I.
-- Create date: 14-11-2014
-- Description:	Добавление / редактирование оплаты по договору аренды
-- Modified:    18-03-2015
-- ModifiedBy:  Butakov I.
-- Description:	Удалено поле isPayment
-- update:		kav 2020-08-27 были неправильно местами поставлены isToTenant и isCash
-- =============================================
ALTER PROCEDURE [Arenda].[AddEditPayment]
	@id int,
	@id_Agreements int,
	@Date datetime,
	@Summa decimal(12,2),	
	@id_PayType int,
	@PlaneDate date,
	@isRealMoney bit,
	@isSendMoney bit,
	@id_Fines int = null,
	@id_Editor int,
	@Description varchar(1024) = ''
	AS
BEGIN

declare @days int = 0				-- просрочка в днях
declare @peni numeric (12,2) = 0	-- величина начисленного пени
declare @payed numeric (12,2) = 0	-- величина, принятая к оплате
declare @debt numeric (12,2) = 0	-- оставшийся долг по оплате

if (@id = 0)
begin

	INSERT INTO [Arenda].[j_PaymentContract]
			   ([id_Agreements]
			   ,[Date]
			   ,[Summa]		
			   ,[id_PayType]
			   ,[PlaneDate]			   
			   ,[isCash]
			   ,[isToTenant]
			   ,[id_Fines]
			   ,[DateEdit]
			   ,[id_Editor]
			   ,[Description])
		 VALUES
			   (@id_Agreements
			   ,@Date
			   ,@Summa		
			   ,@id_PayType
			   ,@PlaneDate
			   ,@isRealMoney
			   ,@isSendMoney
			   ,@id_Fines
			   ,GETDATE()
			   ,@id_Editor
			   ,@Description)
			   
	set @id = SCOPE_IDENTITY()
	
	DECLARE @isFullPayment bit = 0;
	DECLARE @ResultSum numeric(17,2), @tmpValue numeric(17,2)
	select @ResultSum = SUM(Summa) from Arenda.j_PaymentContract where id_Agreements = @id_Agreements --and id <> @id ?
	set @ResultSum = isnull(@ResultSum,0.00) + @Summa

	IF EXISTS (select TOP(1) id from Arenda.s_PlanPeriodLeave where id_Agreements = @id_Agreements)
		BEGIN
			select @tmpValue= SUM(SummaPlan) from Arenda.s_PlanPeriodLeave where id_Agreements = @id_Agreements
			IF @tmpValue<=@ResultSum
				UPDATE Arenda.j_Agreements SET fullPayed  = 1 WHERE id = @id_Agreements
		END
	ELSE IF EXISTS (select TOP(1) id from Arenda.s_PlanPeriodAgreements where id_Agreements = @id_Agreements)
		BEGIN
			select @tmpValue= SUM(SummaPlan) from Arenda.s_PlanPeriodAgreements where id_Agreements = @id_Agreements
			IF @tmpValue<=@ResultSum
				BEGIN
					UPDATE Arenda.j_Agreements SET fullPayed  = 1 WHERE id = @id_Agreements
					set @isFullPayment = 1;
				END
		END
end

select 
	@id as id, 
	@days as [days], 	
	@peni as peni,
	@payed as payed,
	@debt as debt,
	@isFullPayment as isFullPayment

END
