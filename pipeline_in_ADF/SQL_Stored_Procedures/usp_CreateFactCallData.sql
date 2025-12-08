/****** Object:  StoredProcedure [dbo].[usp_CreateFactCallData]    Script Date: 12/8/2025 11:55:21 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_CreateFactCallData]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BatchSize INT = 1000; -- Process 10,000 rows per batch
    DECLARE @LastID INT = 0;

    WHILE 1 = 1
    BEGIN
        -- Drop temp table from previous iteration if exists
        IF OBJECT_ID('tempdb..#NextFactBatch') IS NOT NULL
            DROP TABLE #NextFactBatch;

        -- Get next batch of new records from TransformedCallData
        SELECT TOP (@BatchSize)
            t.ID,
            t.Call_Duration_Seconds AS CallDuration,
            t.Call_Start_Hour AS CallStartHour,
            t.Call_Network_Volume AS CallNetworkVolume,
            t.CALL_START_DT_TM AS StartDate,
            t.CALL_END_DT_TM AS EndDate,
            t.MSISDN,
            t.IMEI,
            t.Lac_Id,
            t.Site_Id,
            t.lat,
            t.longitude,
            t.Cell_SITE_ID,
            -- Foreign Keys (nullable, Power BI will relate them)
            r.ReceiverID,
            c.CallTypeID,
            b.BoundID,
            s.SuspectID,
            tac.TacID,
			t.location
        INTO #NextFactBatch
        FROM TransformedCallData t
        LEFT JOIN DimReceiver r ON r.CallDialedNum = t.CALL_DIALED_NUM
        LEFT JOIN DimCallType c ON c.Type = t.CALL_TYPE
        LEFT JOIN DimInboundOutbound b ON b.InboundOutboundInd = t.INBOUND_OUTBOUND_IND
        LEFT JOIN (
			SELECT IMEI, MIN(SuspectID) AS SuspectID
			FROM DimSuspect
			GROUP BY IMEI
		) s ON s.IMEI = t.IMEI
        LEFT JOIN DimTac tac ON tac.TAC = t.TAC
        WHERE t.ID > @LastID
        AND NOT EXISTS (
            SELECT 1 FROM FactCallData f
            WHERE f.MSISDN = t.MSISDN
              AND f.IMEI = t.IMEI
              AND f.StartDate = t.CALL_START_DT_TM
        )
        ORDER BY t.ID;

        -- Exit loop if no more rows
        IF NOT EXISTS (SELECT 1 FROM #NextFactBatch)
            BREAK;

        -- Insert the batch into FactCallData
        INSERT INTO FactCallData (
            CallDuration, CallStartHour, CallNetworkVolume,
            StartDate, EndDate, MSISDN, IMEI, Lac_Id, Site_Id,
            Lat, Longitude, Cell_SITE_ID, ReceiverID, CallTypeID,
            BoundID, SuspectID, TacID, location
        )
        SELECT DISTINCT
            CallDuration, CallStartHour, CallNetworkVolume,
            StartDate, EndDate, MSISDN, IMEI, Lac_Id, Site_Id,
            Lat, Longitude, Cell_SITE_ID, ReceiverID, CallTypeID,
            BoundID, SuspectID, TacID, location
        FROM #NextFactBatch;

        -- Update last processed ID
        SELECT @LastID = MAX(ID) FROM #NextFactBatch;
    END
END;
