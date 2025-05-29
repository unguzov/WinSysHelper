USE master;
GO

SET NOCOUNT ON

-- Drop the database if it exists
IF DB_ID('performance_test') IS NOT NULL
BEGIN
    ALTER DATABASE performance_test SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE performance_test;
END
GO

-- Create new database
CREATE DATABASE performance_test;
GO

USE performance_test;
GO

-- Create tables
CREATE TABLE tblAuthors (
    Id INT IDENTITY PRIMARY KEY,
    Author_name NVARCHAR(50),
    country NVARCHAR(50)
);

CREATE TABLE tblBooks (
    Id INT IDENTITY PRIMARY KEY,
    Auhthor_id INT FOREIGN KEY REFERENCES tblAuthors(Id),
    Price INT,
    Edition INT
);

-- Table for storing timing results
CREATE TABLE PerfResults (
    Operation NVARCHAR(50),
    DurationSeconds FLOAT
);
GO

-- Insert records and measure time
DECLARE @startInsertTime DATETIME2 = SYSDATETIME();

DECLARE @Id INT = 1;
WHILE @Id <= 100000
BEGIN 
    INSERT INTO tblAuthors (Author_name, country) 
    VALUES (
        'Author - ' + CAST(@Id AS NVARCHAR(10)),
        'Country - ' + CAST(@Id AS NVARCHAR(10)) + ' name'
    );

    INSERT INTO tblBooks (Auhthor_id, Price, Edition) 
    VALUES (@Id, @Id + 2054, @Id + 10000);

    SET @Id = @Id + 1;
END

DECLARE @endInsertTime DATETIME2 = SYSDATETIME();
DECLARE @durationSeconds INT = DATEDIFF(SECOND, @startInsertTime, @endInsertTime);

INSERT INTO PerfResults (Operation, DurationSeconds)
VALUES ('Insert', @durationSeconds);

PRINT 'INSERT Duration (seconds): ' + CAST(@durationSeconds AS NVARCHAR(10));
GO

-- Read records and measure time, suppressing output
DECLARE @startReadTime DATETIME2 = SYSDATETIME();
DECLARE @counter INT = 1;

-- Declare a table variable to hold results and suppress output
DECLARE @dummy TABLE (
    Id INT,
    Author_name NVARCHAR(50),
    country NVARCHAR(50),
    Price INT,
    Edition INT
);

WHILE @counter <= 300
BEGIN
    -- Insert into dummy table to force data read and suppress output
    INSERT INTO @dummy
    SELECT 
        a.Id, 
        a.Author_name, 
        a.country, 
        b.Price, 
        b.Edition
    FROM 
        tblAuthors a
    INNER JOIN 
        tblBooks b
    ON 
        a.Id = b.Auhthor_id;

    SET @counter = @counter + 1;
END

DECLARE @endReadTime DATETIME2 = SYSDATETIME();
DECLARE @durationSeconds INT = DATEDIFF(SECOND, @startReadTime, @endReadTime);

INSERT INTO PerfResults (Operation, DurationSeconds)
VALUES ('Read', @durationSeconds);

PRINT 'READ Duration (seconds): ' + CAST(@durationSeconds AS NVARCHAR(10));
GO

-- Final Output
SELECT 
    Operation,
    DurationSeconds AS [Duration (Seconds)]
FROM 
    PerfResults;
GO

SET NOCOUNT OFF

-- Drop the pertormance_test database
USE master;
GO

IF DB_ID('performance_test') IS NOT NULL
BEGIN
    ALTER DATABASE performance_test SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE performance_test;
END
GO
