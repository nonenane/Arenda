USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[AddEditSec]    Script Date: 16.12.2020 15:58:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:			Cvetkov K.
-- Create date:		unknown
-- Description:		Процедура добавления / редактирования секции
-- Modified by:		Butakov I.A.
-- Modify date:		30-01-2015
-- Modification:	Добавление колонки isAPPZ
-- Editor:			Molotkova_IS
-- Edit date:		07-12-2019
-- Description:		Добавлено поле id_ObjectLease
-- =============================================
ALTER PROCEDURE [Arenda].[AddEditSec]
	@cName varchar(50),
	@id_bl varchar(50),
	@id_fl varchar(50),
	@mode int,
	@id int,
	@isActive int,
	@lamps numeric (2,0) = NULL,
	@telephone_lines numeric (2,0) = NULL,
	@phone_number varchar (14)= NULL,
	@Total_Area decimal(12, 2),
	@Area_of_Trading_Hall decimal(12, 2),
	@isAPPZ bit = 1,
	@id_Obj int = NULL
	,@id_user int = null
AS
BEGIN
	SET NOCOUNT ON;

	-- добавление
	if @mode = 1 
	Begin 	
		INSERT INTO [Arenda].[s_Sections]
			   ([cName], [id_Building], [id_Floor], [isActive], [Lamps],[Telephone_lines], [Phone_number], [Total_Area], [Area_of_Trading_Hall],
			   [isAPPZ], [id_ObjectLease],id_Creator,id_Editor,DateCreate,DateEdit) 
		 VALUES
			   (@cName,
			   (select b.[id] from Arenda.s_Building b where b.cName = @id_bl),
			   (select f.[id] from Arenda.s_Floors f where f.cName = @id_fl),
			   1, @lamps, @telephone_lines, @phone_number, @Total_Area, @Area_of_Trading_Hall, @isAPPZ, @id_Obj,@id_user,@id_user,GETDATE(),GETDATE())
		
		select SCOPE_IDENTITY()
	End
	
	-- редактирование
	if @mode = 0 
	begin
		Update Arenda.[s_Sections]
		Set	
			cName = @cName,
			id_Building = (select [id] from Arenda.s_Building where cName = @id_bl), 
			id_Floor = (select [id] from Arenda.s_Floors where cName = @id_fl),
			isActive = @isActive,
			Lamps = @lamps,
			Telephone_lines = @telephone_lines,
			Phone_number = @phone_number,
			Total_Area = @Total_Area,
			Area_of_Trading_Hall = @Area_of_Trading_Hall,
			isAPPZ = @isAPPZ,
			id_ObjectLease = @id_Obj
			,id_Editor = @id_user,DateEdit = GETDATE()
		Where		
			id = @id
			
		select @id			
	end
	
	--изменение площади
	if @mode = 3 
	begin
		Update Arenda.[s_Sections]
		Set			
			Total_Area = @Total_Area,
			Area_of_Trading_Hall = @Area_of_Trading_Hall,id_Editor = @id_user,DateEdit = GETDATE()
		Where		
			id = @id
			
		select @id
	end
	
	
	
	
END
