USE [dbase2]
GO
/****** Object:  StoredProcedure [Arenda].[getBanks]    Script Date: 17.12.2020 14:54:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Editor:		Molotkova_IS
-- Edit date:	11-03-2020
-- Description:	Добавлен признак Used
-- =============================================
ALTER PROCEDURE [Arenda].[getBanks]
	-- Add the parameters for the stored procedure here
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--Select * from [Arenda2].[s_Banks]
	SELECT
		sB.id,
		LTRIM(RTRIM(sB.cName)) as cName,
		sB.CorrespondentAccount,
		sB.BIC,
		sB.isActive,
		CASE WHEN MIN(sLT.id) IS NULL THEN 0 ELSE 1 END AS Used
	FROM [Arenda].[s_Banks] sB
		--LEFT JOIN [Arenda].[s_Landlord_Tenant] sLT on sLT.id_Bank = sB.id
		LEFT JOIN [Arenda].s_LandlordTenantBank sLT on sLT.id_Bank = sB.id
	GROUP BY sB.id, sB.cName, sB.CorrespondentAccount, sB.BIC, sB.isActive
END
