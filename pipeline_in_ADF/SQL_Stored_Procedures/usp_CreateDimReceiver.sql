/****** Object:  StoredProcedure [dbo].[usp_CreateDimReceiver]    Script Date: 12/8/2025 11:03:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_CreateDimReceiver]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO DimReceiver (CallDialedNum, ReceiverCountry, ReceiverNetwork)
    SELECT DISTINCT
        CALL_DIALED_NUM,
        Receiver_Country,
        Receiver_Network
    FROM TransformedCallData t
    WHERE NOT EXISTS (
        SELECT 1 FROM DimReceiver d WHERE d.CallDialedNum = t.CALL_DIALED_NUM
    );
END;
