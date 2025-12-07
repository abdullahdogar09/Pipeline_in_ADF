/****** Object:  StoredProcedure [dbo].[usp_TransformRawCallData]    Script Date: 12/7/2025 11:56:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_TransformRawCallData]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BatchSize INT = 1000;  -- Number of rows per batch
    DECLARE @LastID INT = 0;

    WHILE 1 = 1
    BEGIN
        -- Drop temp table if it exists from previous iteration
        IF OBJECT_ID('tempdb..#NextBatch') IS NOT NULL
            DROP TABLE #NextBatch;

        -- Get next batch of rows from RawCallData
        SELECT TOP (@BatchSize)
            r.ID,
            r.MSISDN,
            r.CALL_DIALED_NUM,
            r.IMSI,
            r.IMEI,
            TRY_CONVERT(DATETIME, r.CALL_START_DT_TM, 0) AS CALL_START_DT_TM,
            TRY_CONVERT(DATETIME, r.CALL_END_DT_TM, 0) AS CALL_END_DT_TM,
            r.INBOUND_OUTBOUND_IND,
            r.Call_Network_Volume,
            r.Lac_Id,
            r.Site_Id,
            r.Cell_SITE_ID,
            r.lat,
            r.longitude,
            r.CALL_TYPE,
            r.location,
            r.TAC,
            ISNULL(r.Company, 'Unknown') AS Company,
            ISNULL(r.Model, 'Unknown') AS Model,

            -- Dialer Country
            CASE
                WHEN r.MSISDN = 'internet' THEN 'Online Call'
                WHEN r.MSISDN LIKE '92%' THEN 'Pakistan'
                ELSE 'Unknown'
            END AS Dialer_Country,

            -- Dialer Network
            CASE 
                WHEN SUBSTRING(r.MSISDN, 3, 3) = '339' THEN 'Onic'
                WHEN SUBSTRING(r.MSISDN, 3, 3) = '355' THEN 'SCO'
                WHEN SUBSTRING(r.MSISDN, 3, 3) IN ('300','301','302','303','304','305','306','307','308','309',
                                       '320','321','322','323','324','325','326','327','328','329') THEN 'Jazz'
                WHEN SUBSTRING(r.MSISDN, 3, 3) IN ('310','311','312','313','314','315','316','317','318','319','350') THEN 'Zong'
                WHEN SUBSTRING(r.MSISDN, 3, 3) IN ('340','341','342','343','344','345','346','347','348','349') THEN 'Telenor'
                WHEN SUBSTRING(r.MSISDN, 3, 3) IN ('330','331','332','333','334','335','336','337','338') THEN 'Ufone'
                ELSE 'Unknown'
            END AS Dialer_Network,

            -- Receiver Country
            CASE
                WHEN r.CALL_DIALED_NUM = 'internet' THEN 'Online Call'
                WHEN r.CALL_DIALED_NUM LIKE '92%' THEN 'Pakistan'
                ELSE 'Unknown'
            END AS Receiver_Country,

            -- Receiver Network
            

            -- Call Duration
            DATEDIFF(SECOND, 
                TRY_CONVERT(DATETIME, r.CALL_START_DT_TM, 0), 
                TRY_CONVERT(DATETIME, r.CALL_END_DT_TM, 0)
            ) AS Call_Duration_Seconds,

            -- Call Start Hour
            DATEPART(HOUR, TRY_CONVERT(DATETIME, r.CALL_START_DT_TM, 0)) AS Call_Start_Hour
        INTO #NextBatch
        FROM RawCallData r
        WHERE r.ID > @LastID
        AND NOT EXISTS (
            SELECT 1 FROM TransformedCallData t
            WHERE t.MSISDN = r.MSISDN
              AND t.IMEI = r.IMEI
              AND t.CALL_START_DT_TM = TRY_CONVERT(DATETIME, r.CALL_START_DT_TM, 0)
        )
        ORDER BY r.ID;

        -- Exit loop if no more rows
        IF NOT EXISTS (SELECT 1 FROM #NextBatch)
            BREAK;

        -- Insert next batch into TransformedCallData
        INSERT INTO TransformedCallData (
            ID, MSISDN, CALL_DIALED_NUM, IMSI, IMEI, CALL_START_DT_TM,
            CALL_END_DT_TM, INBOUND_OUTBOUND_IND, Call_Network_Volume,
            Lac_Id, Site_Id, Cell_SITE_ID, lat, longitude, CALL_TYPE,
            location, TAC, Company, Model, Dialer_Country, Dialer_Network,
            Receiver_Country, Receiver_Network, Call_Duration_Seconds, Call_Start_Hour
        )
        SELECT * FROM #NextBatch;

        -- Update @LastID for next batch
        SELECT @LastID = MAX(ID) FROM #NextBatch;
    END
END;

