/****** Object:  StoredProcedure [dbo].[usp_CreateDimCallType]    Script Date: 11/16/2025 5:30:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_CreateDimCallType]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO DimCallType (Type)
    SELECT DISTINCT
        CALL_TYPE
    FROM TransformedCallData t
    WHERE NOT EXISTS (
        SELECT 1 FROM DimCallType d WHERE d.Type = t.CALL_TYPE
    );
END;
