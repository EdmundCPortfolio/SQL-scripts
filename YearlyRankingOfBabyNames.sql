/*

File: YearlyRankingOfBabyNames.sql
Author: EC

Description:
Query returns the most popular baby names for girls in England and Wales, ranking by each year.
Script is in 4 parts
1.	Create staging  and temp tables for transformations.
2.	Import the top 100 names for years 2017 to 2020 using a while loop. Source spreadsheets are formatted into 2 tables.
3.	Import top 100 names for the year 2021. Source spreadsheet is formatted into 1 table.
4.	Query staging table to create crosstab of names and the associated yearly rank. 


Source data : https://www.ons.gov.uk/peoplepopulationandcommunity/birthsdeathsandmarriages/livebirths/datasets/babynamesenglandandwalesbabynamesstatisticsgirls

*/


-- Step 1: Create Staging and temp tables

IF OBJECT_ID('stgTblBabyNames', 'U') IS NOT NULL
    DROP TABLE stgTblBabyNames;

CREATE TABLE stgTblBabyNames  (
Fname VARCHAR(255)
,PopulationCount INT
,Gender CHAR(1)
,BirthYear CHAR(4)
,DataSource VARCHAR(255)
,DateOfImport VARCHAR(50)
);

IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL
    DROP TABLE #TempTable;


CREATE TABLE #TempTable (
    Fname1 VARCHAR(255),
    Total1 VARCHAR(255),
    Fname2 VARCHAR(255),
    Total2 VARCHAR(255),
    Gender CHAR(1),
    BirthYear CHAR(4),
    DataSource VARCHAR(255),
    DateOfImport VARCHAR(50)
);


-- Step 2: Import data for years 2017 to 2020. Note year 2021 is in a different format and is handled in Step 3

DECLARE @Year INT = 2017;
WHILE @Year <= 2020
BEGIN
    DECLARE @FilePath NVARCHAR(500) = 'D:\NationalData\Load\RankOfNames\Datset\Female\' + CAST(@Year AS NVARCHAR(4)) + 'girlsnames.xls';

    DECLARE @Command  NVARCHAR(MAX);
    SET @Command  = N'
        INSERT INTO #TempTable (Fname1, Total1, Fname2, Total2, Gender, BirthYear, DataSource, DateOfImport)
        SELECT  
            F2,
            F3,
            F8,
            F9,
            ''F'' AS Gender,
            ''' + CAST(@Year AS CHAR(4)) + ''' AS BirthYear,
            ''' + @FilePath + ''' AS DataSource,
            GETDATE() AS DateOfImport
        FROM OPENROWSET 
        (''Microsoft.ACE.OLEDB.12.0'', ''Excel 12.0;Database=' + @FilePath + ';HDR=NO'', ''SELECT * FROM [Table 1$]'') AS A
        WHERE
            F2 IS NOT NULL 
            AND F2 <> ''NAME''';

    EXEC sp_executesql @Command;

    SET @Year = @Year + 1;
END

--Unpivot the data and insert into Staging table
INSERT INTO stgTblBabyNames(Fname, PopulationCount ,Gender, BirthYear,DataSource,DateOfImport)
SELECT 
Fname1 AS Fname
,CAST(REPLACE(Total1,',','') AS INT) AS PopulationCount
,Gender
,BirthYear
,DataSource
,DateOfImport
FROM #TempTable 

UNION ALL

SELECT 
Fname2 AS Fname
,CAST(REPLACE(Total2,',','') AS INT) AS PopulationCount
,Gender
,BirthYear
,DataSource
,DateOfImport
FROM #TempTable;

-- clean up 
IF OBJECT_ID('tempdb..#TempTable') IS NOT NULL
    DROP TABLE #TempTable;


-- Step 3: Load data for 2021 into Staging table

INSERT INTO stgTblBabyNames(Fname, PopulationCount ,Gender, BirthYear,DataSource,DateOfImport)
SELECT  
UPPER(F2)  AS Fname
,CAST(REPLACE(F3,',','') AS INT) AS 'PopulationCount'
,'F' AS 'Gender'
,'2021' AS 'BirthYear'
,'E:\Work Files\SQL\Database Code\RankOfNames\Datset\Female\' + '2021girlsnames.xls' AS 'DataSource'
,GETDATE() AS 'DateOfImport'
FROM OPENROWSET 
('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=D:\NationalData\Load\RankOfNames\Datset\Female\2021girlsnames.xlsx;HDR=NO', 'select * from [1$]') AS A
WHERE
    F2 IS NOT NULL 
	AND F2 <> 'NAME';


-- Step 4: Crosstab of the Top 20 names

SELECT * FROM 
(
	SELECT
	Fname
	,Gender
	,MAX(CASE WHEN BirthYear = 2017 THEN [RANK] END) AS [Rank_2017]
	,MAX(CASE WHEN BirthYear = 2018 THEN [RANK] END) AS [Rank_2018]
	,MAX(CASE WHEN BirthYear = 2019 THEN [RANK] END) AS [Rank_2019]
	,MAX(CASE WHEN BirthYear = 2020 THEN [RANK] END) AS [Rank_2020]
	,MAX(CASE WHEN BirthYear = 2021 THEN [RANK] END) AS [Rank_2021]
	FROM
	(
		SELECT
			Fname,
			Gender,
			BirthYear,
			PopulationCount,
			RANK() OVER (PARTITION BY BirthYear ORDER BY PopulationCount DESC) AS [RANK]
		FROM stgTblBabyNames
	) AS AllNamesByRank
	GROUP BY Fname, Gender
) AS Top102021

WHERE [Rank_2021] <= 20
ORDER BY [Rank_2021] ASC;