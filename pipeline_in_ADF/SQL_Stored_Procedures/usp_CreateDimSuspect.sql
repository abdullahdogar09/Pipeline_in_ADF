/****** Object:  StoredProcedure [dbo].[usp_CreateDimSuspect]    Script Date: 12/8/2025 11:07:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_CreateDimSuspect]
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO DimSuspect (DialerCountry, DialerNetwork, IMEI, IMSI, MSISDN)
        SELECT DISTINCT
            Dialer_Country,
            Dialer_Network,
            IMEI,
            IMSI,
            MSISDN
        FROM TransformedCallData t
        WHERE t.IMEI IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM DimSuspect d WHERE d.IMEI = t.IMEI
        );
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() IN (2627, 2601)
        BEGIN
            PRINT 'Duplicate IMEI detected, skipping insert.';
        END
        ELSE
        BEGIN
            -- Fallback for unexpected errors
            DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT;
            SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE();
            RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        END
    END CATCH
END;
