/*

File: UnpivotPopulationEstimate.sql
Author: EC
Data Source: Please see the script UnpivotPopulationEstimate.sql to create and populate the table stgTblPopulationEstimate

*/

DECLARE @Colname VARCHAR(255)
DECLARE @TableName VARCHAR(255)
DECLARE @ColValues VARCHAR(8000)
DECLARE @ColUnpivot VARCHAR(8000)
DECLARE @Command NVARCHAR(MAX)

SET @TableName = 'stgTblPopulationEstimates'
SET @Colname = 'population'

-- Columns to unpivot
SET @ColUnpivot = (
    SELECT STRING_AGG(QUOTENAME(name), ',') AS UnpivotList
    FROM sys.columns
    WHERE [object_id] = OBJECT_ID(@TableName)
    AND (Name LIKE @Colname + '%')
)

-- All Column names
SET @ColValues = (
    SELECT STRING_AGG(QUOTENAME(name), ',') AS UnpivotList
    FROM sys.columns
    WHERE [object_id] = OBJECT_ID(@TableName)
)

-- Construct dynamic SQL command
SET @Command = N'
    SELECT *
    FROM (
        SELECT ' + @ColValues + '
        FROM ' + @TableName + '
    ) AS P
    UNPIVOT (
        PopulationSize FOR YearPeriod IN (' + @ColUnpivot + ')
    ) AS upvt'

-- Execute dynamic SQL
EXEC sp_executesql @Command
