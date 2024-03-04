/*

File: NetChangeUsingHashFunction.sql
Author: EC
Description : Script demonstrating a hashing algorithm to identify new, updated and deleted records 

*/

-- Create Employee table
CREATE TABLE Employee(
EmployeeId varchar(25), 
FirstName VARCHAR(50), 
SurName VARCHAR(50), 
Email varchar(255), 
MobileNum varchar(25), 
Salary INT,
HashValue VARBINARY(255))


-- Insert the initial set of employees’ details
IF EXISTS (
	SELECT * FROM sys.objects
	WHERE object_id = OBJECT_ID('Employee') AND type = 'u'
)
BEGIN 

INSERT INTO Employee (EmployeeId, FirstName, SurName, Email, MobileNum, Salary)
VALUES ('OPS569982312', 'Steven', 'Jones', 'StevenJones@GoldComputersLtd.COM', '07912345678', 50000)
INSERT INTO Employee (EmployeeId, FirstName, SurName, Email, MobileNum, Salary)
VALUES ('OPS265974559', 'Lucy', 'Addison', 'LucyAddison@GoldComputersLtd.COM', '07988845823', 77000)
INSERT INTO Employee (EmployeeId, FirstName, SurName, Email, MobileNum, Salary)
VALUES ('ACC512555648', 'Amy', 'Brown', 'AmyBrownn@GoldComputersLtd.COM', '07911254556', 120000)
END


-- Add the hash value to employee table. Exclude the EmployeeID column from the hash
UPDATE Employee
SET HashValue = HASHBYTES('SHA2_256', 
    ISNULL(CONVERT(VARBINARY(MAX), FirstName), 0x) +
    ISNULL(CONVERT(VARBINARY(MAX), SurName), 0x) +
    ISNULL(CONVERT(VARBINARY(MAX), Email), 0x) +
	ISNULL(CONVERT(VARBINARY(MAX), MobileNum), 0x) +
	ISNULL(CONVERT(VARBINARY(MAX), Salary), 0x) 
)

/*

SELECT EmployeeId, FirstName, SurName, Email, MobileNum, Salary, HashValue FROM Employee 

*/


--HR sent a refresh of the current employee data. Insert data into a temp table for review.
IF OBJECT_ID('tempdb..#temp', 'U') IS NOT NULL
    DROP TABLE #temp;

CREATE TABLE #temp (
EmployeeId varchar(25), 
    FirstName VARCHAR(50), 
    SurName VARCHAR(50), 
    Email varchar(255), 
    MobileNum varchar(25), 
    Salary INT,
	HashValue VARBINARY(255)
);


-- Insert new records into a temp table
INSERT INTO #temp (EmployeeId, FirstName, SurName, Email, MobileNum, Salary)
VALUES
    ('OPS265974559', 'Lucy', 'Addison', 'LucyAddison@GoldComputersLtd.COM', '07988845823', 87000),
    ('SALES2659745', 'Jake', 'Lee', 'JakeLee@GoldComputersLtd.COM', '07956514508', 60000),
    ('OPS569982312', 'Steven', 'Jones', 'StevenJones@GoldComputersLtd.COM', '07912345678', 50000),
	('SALES5684511', 'Karen', 'Gallagher', 'Karen.Gallagher@GoldComputersLtd.com', '0795648951', 65000);


-- Add hash to the temp table
UPDATE #temp
SET HashValue = HASHBYTES('SHA2_256', 
    ISNULL(CONVERT(VARBINARY(MAX), FirstName), 0x) +
    ISNULL(CONVERT(VARBINARY(MAX), SurName), 0x) +
    ISNULL(CONVERT(VARBINARY(MAX), Email), 0x) +
	ISNULL(CONVERT(VARBINARY(MAX), MobileNum), 0x) +
	ISNULL(CONVERT(VARBINARY(MAX), Salary), 0x) 
)


-- Check which employees have are new hires, left the organisation or had their personal details updated 
SELECT
Employee.EmployeeId
,Employee.FirstName
, Employee.SurName
,Employee.HashValue
,CASE
	WHEN Employee.HashValue = #temp.HashValue THEN 'No change to staff record'
	WHEN Employee.EmployeeId IS NOT NULL AND Employee.HashValue <> #temp.HashValue THEN 'Change to personal information'
	WHEN #temp.EmployeeId IS NULL THEN 'Employee has left organisation. Deletion required'
	END 'Type Of Update Required'
FROM Employee
LEFT OUTER JOIN #temp
	ON Employee.EmployeeId = #temp.EmployeeId

UNION ALL 

SELECT
#temp.EmployeeId
,#temp.FirstName
,#temp.SurName
,#temp.HashValue
,CASE
	WHEN #temp.EmployeeId IS NOT NULL THEN 'New Employee'
	END AS 'Type Of Update Required'
FROM #temp
LEFT OUTER JOIN Employee
	ON #temp.EmployeeId = Employee.EmployeeId 
WHERE Employee.EmployeeId  IS NULL

GO
