--Create landing table
CREATE TABLE DowJonesDailyClose (
    [Date] VARCHAR(19),
    [Open] FLOAT,
    [High] FLOAT,
    [Low]  FLOAT,
    [Close] FLOAT
);


--Example 1, Bulk inset a csv file
BULK INSERT DowJonesDailyClose 
FROM 'E:\SQL\Database Code\BulkInsert\DowJonesData\DJIA.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, -- Skip the header row
    BATCHSIZE = 100000, -- Process 100,000 records per batch
    CODEPAGE = '65001' -- Use UTF-8 encoding
    
);


--Example 2, Bulk inset a text file, pipe delimited
BULK INSERT DowJonesDailyClose 
FROM 'E:\SQL\Database Code\BulkInsert\DowJonesData\\DJIA_Pipe.txt'
WITH (
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2, -- Skip the header row
    BATCHSIZE = 100000, -- Process 100,000 records per batch
    CODEPAGE = '65001' -- Use UTF-8 encoding
    
);


GO
