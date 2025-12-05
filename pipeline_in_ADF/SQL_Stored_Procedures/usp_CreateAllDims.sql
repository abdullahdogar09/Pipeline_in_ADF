/****** Object:  StoredProcedure [dbo].[usp_CreateAllDims]    Script Date: 11/16/2025 5:28:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_CreateAllDims]
AS
BEGIN
    EXEC usp_CreateDimReceiver;
    EXEC usp_CreateDimCallType;
    EXEC usp_CreateDimInboundOutbound;
    EXEC usp_CreateDimSuspect;
    EXEC usp_CreateDimTac;
END;