/*

File: DynamicUnpivotPopulationEstimates.sql
Author: EC

Description:
The SQL script defines a stored procedure named UnionTablesByYear that dynamically generates and executes a query to union all tables in the database whose names contain a specific year.
This approach allows the union to handle additional tables.
In sample data below, the Site LDN, does not have a table for 202324.  The Union query will dynamically include the additional table for the year 202425


*/

-- Create tables

IF OBJECT_ID('OfficeNYC_202324', 'U') IS NOT NULL
    DROP TABLE OfficeNYC_202324;
GO

CREATE TABLE OfficeNYC_202324 (
    OFFICE CHAR(3),
    HeadCount INT,
    ReportingYear INT
);
GO

IF OBJECT_ID('OfficeTYO_202324', 'U') IS NOT NULL
    DROP TABLE OfficeTYO_202324;
GO

CREATE TABLE OfficeTYO_202324 (
    OFFICE CHAR(3),
    HeadCount INT,
    ReportingYear INT
);
GO

IF OBJECT_ID('OfficeLDN_202425', 'U') IS NOT NULL
    DROP TABLE OfficeLDN_202425;
GO

CREATE TABLE OfficeLDN_202425 (
    OFFICE CHAR(3),
    HeadCount INT,
    ReportingYear INT
);
GO

IF OBJECT_ID('OfficeNYC_202425', 'U') IS NOT NULL
    DROP TABLE OfficeNYC_202425;
GO

CREATE TABLE OfficeNYC_202425 (
    OFFICE CHAR(3),
    HeadCount INT,
    ReportingYear INT
);
GO

IF OBJECT_ID('OfficeTYO_202425', 'U') IS NOT NULL
    DROP TABLE OfficeTYO_202425;
GO

CREATE TABLE OfficeTYO_202425 (
    OFFICE CHAR(3),
    HeadCount INT,
    ReportingYear INT
);
GO


-- insert sample data
INSERT INTO OfficeNYC_202324 (OFFICE, HeadCount, ReportingYear)
VALUES('NYC', 600, 2023);

INSERT INTO OfficeTYO_202324 (OFFICE, HeadCount, ReportingYear)
VALUES('TYO', 700, 2023);

INSERT INTO OfficeLDN_202425 (OFFICE, HeadCount, ReportingYear)
VALUES('LDN', 500, 2024);

INSERT INTO OfficeNYC_202425 (OFFICE, HeadCount, ReportingYear)
VALUES('NYC', 800, 2024);

INSERT INTO OfficeTYO_202425 (OFFICE, HeadCount, ReportingYear)
VALUES('TYO', 950, 2024);

-- note LDN does not have a 202324 table

GO


-- Create store procedure
IF OBJECT_ID('UnionTablesByYear', 'P') IS NOT NULL
    DROP PROCEDURE UnionTablesByYear;
GO

CREATE PROCEDURE UnionTablesByYear
    @Year NVARCHAR(6)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);
    SET @SQL = N'';

    SELECT @SQL = @SQL + N'SELECT * FROM ' + QUOTENAME(name) + N' UNION ALL ' 
    FROM sys.objects 
    WHERE type = 'U' AND name LIKE '%' + @Year + '%';

    -- Remove the last 'UNION ALL'
    IF LEN(@SQL) > 10
        SET @SQL = LEFT(@SQL, LEN(@SQL) - 10) + N';';

    EXEC sp_executesql @SQL;
END;


--EXEC UnionTablesByYear '202425';

GO
