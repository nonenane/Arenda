USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[CheakALL]    Script Date: 28.01.2021 9:59:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,> поиск уже похожих записей.
-- Editor:		Molotkova_IS
-- Edit date:	07-12-2019, 28-02-2020
-- Descriprion:	Добавлена проверка по объекту @id_Obj, Добавлен вывод наименования и isActive, а также проверка по id
-- =============================================
ALTER PROCEDURE [Arenda].[CheakALL]
	@cname varchar(30),
	@prz varchar (5),
	@id_Obj int = null,
	@id int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here>
    IF @prz = 'bl'
    begin
    select id,cName,Abbreviation from Arenda.s_Building b where lower(b.cName) = lower(@cname)
    end
    IF @prz = 'eq'
    Begin
    select id  from Arenda.s_Equipment e where lower(e.cName) = lower(@cname)
    End
    IF @prz = 'fl'
    begin
    select id,cName,Abbreviation from Arenda.s_Floors f where lower(f.cName) = lower(@cname)
    end
    IF @prz = 'tp'
    begin
    select id,cName  from Arenda.s_Type_of_Premises t where lower(t.cName) = lower(@cname)
    end
    
    IF @prz = 'sc'
    begin
    select id  from Arenda.s_Sections s where lower(s.cName) = lower(@cname) and s.id_ObjectLease = @id_Obj
    end
    
   IF @prz = 'too'
    begin
    select id  from Arenda.s_Type_of_Organization s where lower(s.cName) = lower(@cname)
    end
    
    IF @prz = 'bs'
    begin
    select id, cName, isActive,s.Abbreviation,s.needDate from Arenda.s_Basement s where lower(rtrim(ltrim(s.cName))) = lower(rtrim(ltrim(@cname))) and id != @id
    end
    
    IF @prz = 'bk'
    begin
    select id  from Arenda.s_Banks s where lower(s.cName) = lower(@cname)
    end
    
    IF @prz = 'pos'
    begin
    select id  from Arenda.s_Posts s where lower(s.cName) = lower(@cname)
    end
    
END
