USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddEditAnotherPayments]    Script Date: 16.12.2020 15:23:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Butakov I.
-- Create date: 26-02-2015
-- Description:	Добавление / редактирование записи в справочник дополнительных оплат
-- Editor:		Molotkova_IS
-- Edit date:	28-02-2020
-- Description: Проверка на дубли вынесена в отдельную процедуру
-- =============================================
ALTER PROCEDURE [Arenda].[AddEditAnotherPayments]
	@id int,
	@cname varchar(100),@id_user int = null
AS
BEGIN

		if (@id = 0)
		begin
			INSERT INTO [Arenda].[s_AddPayment]
				   ([cName]
				   ,[isActive],id_Creator,id_Editor,DateCreate,DateEdit)
			 VALUES
				   (@cname
				   ,1,@id_user,@id_user,GETDATE(),GETDATE())
		    
			set @id = SCOPE_IDENTITY()
		end
		else
		begin
			UPDATE [Arenda].[s_AddPayment]
			SET [cName] = @cname,id_Editor = @id_user,DateEdit = GETDATE()
			WHERE id = @id
		end

select @id
		
END
