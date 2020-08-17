SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sporykhin G.Y.
-- Create date: 2020-04-25
-- Description:	Запись справочника видов дейстельности
-- =============================================
ALTER PROCEDURE [Arenda].[spg_setTypeActivities]		 
	@id int,
	@cName varchar(max),	
	@isActive bit,
	@id_user int,
	@result int = 0,
	@isDel int
AS
BEGIN
	SET NOCOUNT ON;

BEGIN TRY 
	IF @isDel = 0
		BEGIN

			IF EXISTS (select TOP(1) id from [Arenda].[s_TypeActivities] where id <>@id and LTRIM(RTRIM(LOWER(cName))) = LTRIM(RTRIM(LOWER(@cName))))
				BEGIN
					SELECT -1 as id;
					return;
				END

			IF @id = 0
				BEGIN
					INSERT INTO [Arenda].[s_TypeActivities]  (cName,isActive,id_Editor,DateEdit)
					VALUES (@cName,1,@id_user,GETDATE())

					SELECT  cast(SCOPE_IDENTITY() as int) as id
					return;
				END
			ELSE
				BEGIN
					UPDATE [Arenda].[s_TypeActivities] 
					set		cName = @cName,
							isActive=@isActive,
							id_Editor=@id_user,
							DateEdit=GETDATE()
					where id = @id
										
					SELECT @id as id
					return;
				END
		END
	ELSE
		BEGIN
			IF @result = 0
				BEGIN
					
					IF NOT EXISTS(select TOP(1) id from [Arenda].[s_TypeActivities] where id = @id)
						BEGIN
							select -1 as id
							return;
						END

					
					IF EXISTS(select TOP(1) id from [Arenda].[j_Agreements] where id_TypeActivities = @id)
						BEGIN
							select -2 as id
							return;
						END
					
					select 0 as id
					return;
				END
			ELSE
				BEGIN
					DELETE FROM [Arenda].[s_TypeActivities]  where id = @id
					RETURN
				END
		END
END TRY 
BEGIN CATCH 
	SELECT -9999 as id
	return;
END CATCH
	
END
