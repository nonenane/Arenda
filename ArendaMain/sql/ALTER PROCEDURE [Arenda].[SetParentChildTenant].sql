USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[SetParentChildTenant]    Script Date: 23.12.2020 14:06:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Molotkova_IS
-- Create date: 2019-15-11
-- Description:	Редактирование родителей\детей арендатора
-- =============================================
ALTER PROCEDURE [Arenda].[SetParentChildTenant]
	@id_parent int,
	@id_child int,
	@id_creator int
	
AS
BEGIN
SET NOCOUNT ON
	if @id_parent = 0
		set @id_parent = null
	if @id_child = 0
		set @id_child = null
	/*if @id_child = @id_parent
	begin*/
		delete from Arenda.j_ParentChildTenant where id_TenantChild = @id_child or id_TenantParent = @id_parent
	/*end
	else
	begin*/
	if @id_child != @id_parent
	begin
		declare @id int
		select @id = id from Arenda.j_ParentChildTenant where (id_TenantParent = @id_parent or id_TenantParent is null)
		and (id_TenantChild = @id_child or id_TenantChild is null)
		if @id = 0 OR @id is null
		begin
			insert into Arenda.j_ParentChildTenant(id_TenantParent, id_TenantChild, id_Creator, DateCreate)
			values(@id_parent, @id_child, @id_creator, getdate())
		end
		else if @id_parent is not null or @id_child is not null
		begin
			update Arenda.j_ParentChildTenant
			set
				id_TenantParent = @id_parent,
				id_TenantChild = @id_child,
				id_Creator = @id_creator,
				DateCreate = getdate()
			where id_TenantParent = @id_parent OR id_TenantChild = @id_child
		end
	end
END