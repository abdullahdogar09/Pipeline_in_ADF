/****** Object:  StoredProcedure [dbo].[usp_CreateDimInboundOutbound]    Script Date: 11/16/2025 5:31:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_CreateDimInboundOutbound]
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO DimInboundOutbound (InboundOutboundInd)
    SELECT DISTINCT
        INBOUND_OUTBOUND_IND
    FROM TransformedCallData t
    WHERE NOT EXISTS (
        SELECT 1 FROM DimInboundOutbound d WHERE d.InboundOutboundInd = t.INBOUND_OUTBOUND_IND
    );
END;