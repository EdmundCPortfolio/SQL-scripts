
/*

File: UnpivotPopulationEstimate.sql
Author: EC
Data Source: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales
Data Source: Spreadsheet: Mid-2011 to mid-2022 detailed time series edition of this dataset, myebtablesenglandwales20112022v2.xlsx

*/



-- STEP 1 Create staging table which to import data into
CREATE TABLE stgTblPopulationEstimates (
ladcode23 VARCHAR(9),
laname23 VARCHAR(50),
country CHAR(1),
sex CHAR(1),
age TINYINT,
population_2011 INT,
population_2012 INT,
population_2013 INT,
population_2014 INT,
population_2015 INT,
population_2016 INT,
population_2017 INT,
population_2018 INT,
population_2019 INT,
population_2020 INT,
population_2021 INT,
population_2022 INT);



-- STEP 2 OpenRowSet to Import data. NOTE, data in source spreadsheet starts on row 2 eg range A2:Q
INSERT INTO [stgTblPopulationEstimates] (ladcode23,laname23,country,sex,age,population_2011,population_2012,population_2013,population_2014,
population_2015,population_2016,population_2017,population_2018,population_2019,population_2020,population_2021,population_2022)

SELECT  A.ladcode23,A.laname23,A.country,A.sex,A.age,A.population_2011,A.population_2012,A.population_2013,A.population_2014,
A.population_2015,A.population_2016,A.population_2017,A.population_2018,A.population_2019,A.population_2020,A.population_2021,A.population_2022
FROM OPENROWSET 
('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=D:\NationalData\Load\myebtablesenglandwales20112022v2.xlsx;HDR=YES', 'select * from [MYEB1 (2023 Geography)$A2:Q]') AS A;



-- STEP 3 Validate data imported as expected
SELECT COUNT(*) AS 'ImportedNumberOfRows', 57876 AS 'ExpectedNumberofRows'
FROM [stgTblPopulationEstimates];

SELECT *
FROM [stgTblPopulationEstimates]
WHERE
COALESCE (ladcode23, laname23, country, sex, CAST (age AS VARCHAR(50)), CAST (population_2011 AS VARCHAR(50)), CAST (population_2012 AS VARCHAR(50)), 
	CAST (population_2013 AS VARCHAR(50)), CAST (population_2014 AS VARCHAR(50)), CAST (population_2015 AS VARCHAR(50)),
	CAST (population_2016 AS VARCHAR(50)), CAST (population_2017 AS VARCHAR(50)), CAST (population_2018 AS VARCHAR(50)), 
	CAST (population_2019 AS VARCHAR(50)), CAST (population_2020 AS VARCHAR(50)), CAST (population_2021 AS VARCHAR(50)), 
	CAST (population_2022 AS VARCHAR(50))) IS NOT NULL;



-- STEP 4 UNPIVOT data, replacing the yearly populations columns as rows
SELECT * 
FROM
(
SELECT
	ladcode23,
	laname23,
	country,
	sex,
	age
	,population_2011
	,population_2012
	,population_2013
	,population_2014
	,population_2015
	,population_2016
	,population_2017
	,population_2018
	,population_2019
	,population_2020
	,population_2021
	,population_2022
FROM [stgTblPopulationEstimates]
) AS P

UNPIVOT
(
PopulationSize FOR YearPeriod IN (population_2011, population_2012,population_2013,population_2014,population_2015,population_2016
									,population_2017,population_2018,population_2019,population_2020,population_2021,population_2022) 
) AS upvt;
