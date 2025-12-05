/****** Object:  StoredProcedure [dbo].[usp_CreateDimTac]    Script Date: 11/16/2025 5:32:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_CreateDimTac]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO DimTac (TAC, Company, Model)
    SELECT DISTINCT
        TAC,
        Company,
        Model
    FROM TransformedCallData t
    WHERE NOT EXISTS (
        SELECT 1 FROM DimTac d WHERE d.TAC = t.TAC
    );
END;