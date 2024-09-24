/*

File: AutomatedStoredProcedureExecution.sql
Author: EC

Description:
This script creates and populates a table with stored procedure names and descriptions, then sequentially executes each stored procedure, handling any errors that occur during execution

*/


/*
Step 1

Generate a list of stored procedures to simulate executing a series of procedure names which are stored in a table.

*/

CREATE PROCEDURE sp_DateNow AS
SELECT GETDATE() as 'Date Now';
GO

CREATE PROCEDURE sp_SQLversion AS
SELECT @@VERSION;
GO

CREATE PROCEDURE sp_ServerName AS
SELECT @@SERVERNAME AS 'Server Name';
GO

CREATE PROCEDURE sp_DatabaseSize AS
SELECT 
    DB_NAME() AS 'Database Name',
    SUM(size * 8 / 1024) AS 'Size (MB)'
FROM 
    sys.master_files
WHERE 
    type = 0;
GO

CREATE PROCEDURE sp_ListTables AS
SELECT 
    TABLE_NAME 
FROM 
    INFORMATION_SCHEMA.TABLES
WHERE 
    TABLE_TYPE = 'BASE TABLE';
GO

CREATE PROCEDURE sp_UserInfo AS
SELECT 
    name AS 'User Name',
    create_date AS 'Creation Date',
    modify_date AS 'Last Modified Date'
FROM 
    sys.sql_logins;
GO

CREATE PROCEDURE sp_CurrentConnections AS
SELECT 
    DB_NAME(dbid) AS 'Database Name',
    COUNT(dbid) AS 'Number of Connections'
FROM 
    sys.sysprocesses
WHERE 
    dbid > 0
GROUP BY 
    dbid;
GO

/*
Step 2

Create a table to hold the list of stored procedure names and descriptions.

*/


CREATE TABLE Tbl_ProcedureList (
    sp_ID INT IDENTITY(1000,1) PRIMARY KEY,
    sp_name VARCHAR(255),
    sp_Description VARCHAR(255)
);
GO

/*
Step 3

Populate the table with the names of the stored procedures

*/

INSERT INTO Tbl_ProcedureList (sp_name, sp_Description)
VALUES ('sp_DateNow', 'The current date and time');
GO
INSERT INTO Tbl_ProcedureList (sp_name, sp_Description)
VALUES ('sp_SQLversion', 'Version information of the SQL Server instance');
GO
INSERT INTO Tbl_ProcedureList (sp_name, sp_Description)
VALUES ('sp_ServerName', 'Server Name');
GO
INSERT INTO Tbl_ProcedureList (sp_name, sp_Description)
VALUES ('sp_DatabaseSize', 'Total size of the current database in megabytes');
GO
INSERT INTO Tbl_ProcedureList (sp_name, sp_Description)
VALUES ('sp_ListTables', 'List of all tables in the current Database');
GO
INSERT INTO Tbl_ProcedureList (sp_name, sp_Description)
VALUES ('sp_UserInfo', 'List of current logins');
GO
INSERT INTO Tbl_ProcedureList (sp_name, sp_Description)
VALUES ('sp_CurrentConnections', 'List of current connections');
GO


/*
Step 4

Execute each stored procedure, referencing the table ProcedureListTable

*/


BEGIN TRY
    -- Create a temporary table to hold the procedure names
    CREATE TABLE #TempProcedureList (
        RowNum INT IDENTITY(1,1),
        sp_name VARCHAR(255)
    );

    -- Insert the procedure names into the temporary table
    INSERT INTO #TempProcedureList (sp_name)
    SELECT sp_name FROM Tbl_ProcedureList;

    DECLARE @RowNum INT = 1;
    DECLARE @MaxRowNum INT;
    DECLARE @sp_name VARCHAR(255);

    -- Get the total number of procedures
    SELECT @MaxRowNum = COUNT(*) FROM #TempProcedureList;

    -- Loop through each procedure and execute 
    WHILE @RowNum <= @MaxRowNum
    BEGIN
        BEGIN TRY
            SELECT @sp_name = sp_name FROM #TempProcedureList WHERE RowNum = @RowNum;
            EXEC(@sp_name);
        END TRY
        BEGIN CATCH
            -- Handle the error
            PRINT 'Error running procedure: ' + @sp_name;
            PRINT 'Error Message: ' + ERROR_MESSAGE();
        END CATCH;
        SET @RowNum = @RowNum + 1;
    END;

    -- Drop the temporary table
    DROP TABLE #TempProcedureList;
END TRY
BEGIN CATCH
    -- Eroor handling
    PRINT 'Error while running procedure list';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
END CATCH;
GO
