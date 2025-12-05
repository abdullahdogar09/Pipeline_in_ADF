/****** Object:  StoredProcedure [dbo].[usp_MergeStagingToRaw]    Script Date: 11/16/2025 5:26:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_MergeStagingToRaw]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO RawCallData (
        MSISDN, CALL_DIALED_NUM, IMSI, IMEI, CALL_START_DT_TM, CALL_END_DT_TM,
        INBOUND_OUTBOUND_IND, Call_Network_Volume, Lac_Id, Site_Id, Cell_SITE_ID,
        lat, longitude, CALL_TYPE, location, TAC, Company, Model
    )
    SELECT
        u.MSISDN,
        u.CALL_DIALED_NUM,
        u.IMSI,
        u.IMEI,
        u.CALL_START_DT_TM,
        u.CALL_END_DT_TM,
        u.INBOUND_OUTBOUND_IND,
        u.Call_Network_Volume,
        u.Lac_Id,
        u.Site_Id,
        u.Cell_SITE_ID,
        u.lat,
        u.longitude,
        u.CALL_TYPE,
        u.location,
        LEFT(u.IMEI, 8) AS TAC,
        ISNULL(t.Company, 'Unknown') AS Company,
        ISNULL(t.Model, 'Unknown') AS Model
    FROM Stg_UpdatedData u
    LEFT JOIN Stg_TACDB t
        ON LEFT(LTRIM(RTRIM(u.IMEI)), 8) = LTRIM(RTRIM(t.TAC))
    WHERE NOT EXISTS (
        SELECT 1 FROM RawCallData r
        WHERE r.MSISDN = u.MSISDN
          AND r.IMEI = u.IMEI
          AND r.CALL_START_DT_TM = u.CALL_START_DT_TM
    );
END;

