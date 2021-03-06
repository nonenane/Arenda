USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[CheckParentChildTenant]    Script Date: 23.12.2020 14:14:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Molotkova_IS
-- Create date: 2020-03-16
-- Description:	Проверка родителей\детей арендатора
-- =============================================
ALTER PROCEDURE [Arenda].[CheckParentChildTenant]
	@id int,
	@mode int,
	@id_tenant int = 0
	
AS
BEGIN
SET NOCOUNT ON
	IF (@mode = 0)
		SELECT
			jpct.id,
			jpct.id_TenantChild,
			slt1.cName as ConTenant,
			jpct.id_TenantParent,
			slt2.cName as CurrentTenant
		FROM [Arenda].[j_ParentChildTenant] jpct
		LEFT JOIN [Arenda].[s_Landlord_Tenant] slt1 on slt1.id = jpct.id_TenantChild
		LEFT JOIN [Arenda].[s_Landlord_Tenant] slt2 on slt2.id = jpct.id_TenantParent
		WHERE id_TenantParent = @id 
	ELSE
		SELECT
			jpct.id,
			jpct.id_TenantChild,
			slt1.cName as CurrentTenant,
			jpct.id_TenantParent,
			slt2.cName as ConTenant
		FROM [Arenda].[j_ParentChildTenant] jpct
		LEFT JOIN [Arenda].[s_Landlord_Tenant] slt1 on slt1.id = jpct.id_TenantChild
		LEFT JOIN [Arenda].[s_Landlord_Tenant] slt2 on slt2.id = jpct.id_TenantParent
		WHERE id_TenantChild = @id and id_TenantParent <> @id_tenant 
END