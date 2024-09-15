/*

File: OPENROWSET_Import_Export_Example.sql
Author: EC

Description:
This SQL script showcases the T-SQL function OPENROWSET, which allows connections to various data sources such as Excel, text files, Access, and Azure Blob Storage. To utilize OPENROWSET, the Ad Hoc Distributed Queries feature in SQL Server Management Studio (SSMS) must be enabled.

Part A of the script illustrates how to import data from an Excel spreadsheet, while Part B demonstrates how to export data to a CSV file.


*/

--Part A: Import from Excel. 
-- Spreadsheet contians the ISO 3166-1 country codes (https://en.wikipedia.org/wiki/ISO_3166-1_numeric)

USE Lookups
GO

IF OBJECT_ID('dbo.IS0CountryCodes', 'U') IS NOT NULL
    DROP TABLE dbo.IS0CountryCodes
GO

CREATE TABLE dbo.IS0CountryCodes (
    [Code] VARCHAR(5),
    [Country_Name] VARCHAR(100),
    [Notes] VARCHAR(255)
)



INSERT INTO IS0CountryCodes ([Code],[Country_Name], [Notes] )

SELECT  [Code], [Country name],	[Notes]
FROM OPENROWSET 
('Microsoft.ACE.OLEDB.12.0', 'Excel 12.0;Database=E:\SQL\Database Code\Open Row Set Templates\TestImport\ISO_3166-1.xlsx;HDR=YES', 'SELECT * FROM  [Sheet1$]') AS A;

GO



--Part B: Export data to a CSV file. 
--Note: The CSV file must already exist in the destination folder and include the column headings.

INSERT INTO OPENROWSET('Microsoft.ACE.OLEDB.12.0',
                       'Text;Database=E:\SQL\Database Code\Open Row Set Templates\TestExport\;HDR=YES;',
                       'SELECT [CODE], [CountryName], DATE
                        FROM [CountryList.csv]')

SELECT CAST('004' AS VARCHAR(3)) AS [CODE], CAST('Afghanistan' AS VARCHAR(100)) AS [CountryName]	, CAST(GETDATE() AS DATETIME) AS DATE UNION ALL
SELECT CAST('008' AS VARCHAR(3)) AS [CODE], CAST('Albania'AS VARCHAR(100)) AS [CountryName]	, CAST(GETDATE() AS DATETIME) AS DATE UNION ALL
SELECT CAST('010' AS VARCHAR(3)) AS [CODE], CAST('Antarctica' AS VARCHAR(100)) AS [CountryName]	, CAST(GETDATE() AS DATETIME) AS DATE UNION ALL
SELECT CAST('012' AS VARCHAR(3)) AS [CODE], CAST('Algeria' AS VARCHAR(100)) AS [CountryName]	, CAST(GETDATE() AS DATETIME) AS DATE UNION ALL
SELECT CAST('016' AS VARCHAR(3)) AS [CODE], CAST('American Samoa' AS VARCHAR(100)) AS [CountryName]	, CAST(GETDATE() AS DATETIME) AS DATE UNION ALL
SELECT CAST('020' AS VARCHAR(3)) AS [CODE], CAST('Andorra' AS VARCHAR(100)) AS [CountryName]	, CAST(GETDATE() AS DATETIME) AS DATE UNION ALL
SELECT CAST('024' AS VARCHAR(3)) AS [CODE], CAST('Angola' AS VARCHAR(100)) AS [CountryName]	, CAST(GETDATE() AS DATETIME) AS DATE

GO
