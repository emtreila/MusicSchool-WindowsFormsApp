USE Music_School;
GO


DROP TABLE IF EXISTS LessonParticipants;
GO

CREATE TABLE LessonParticipants (
    LessonID INT NOT NULL,
    StudentID INT NOT NULL,
    PRIMARY KEY (LessonID, StudentID),
    FOREIGN KEY (LessonID) REFERENCES Lessons(LessonID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);
GO


DROP TABLE IF EXISTS TestRunTables;
DROP TABLE IF EXISTS TestRunViews;
DROP TABLE IF EXISTS TestRuns;
DROP TABLE IF EXISTS TestTables;
DROP TABLE IF EXISTS TestViews;
DROP TABLE IF EXISTS Tables;
DROP TABLE IF EXISTS Views;
DROP TABLE IF EXISTS Tests;
GO

-- holds the names of database tables that can be included in performance tests
CREATE TABLE Tables (
    TableID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

-- holds the names of database views whose performance will be measured during tests
CREATE TABLE Views (
    ViewID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

-- holds data about different tests
CREATE TABLE Tests (
    TestID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL
);

-- stores which database tables belong to which test, and how many rows should be inserted into each table, and in what order
CREATE TABLE TestTables (
    TestID INT NOT NULL,
    TableID INT NOT NULL,
    NoOfRows INT NOT NULL,
    Position INT NOT NULL,
    PRIMARY KEY(TestID, TableID),
    FOREIGN KEY(TestID) REFERENCES Tests(TestID),
    FOREIGN KEY(TableID) REFERENCES Tables(TableID)
);

-- junction table that stores which views belong to which test
CREATE TABLE TestViews (
    TestID INT NOT NULL,
    ViewID INT NOT NULL,
    PRIMARY KEY(TestID, ViewID),
    FOREIGN KEY(TestID) REFERENCES Tests(TestID),
    FOREIGN KEY(ViewID) REFERENCES Views(ViewID)
);

-- stores each run of a test, including timestamps and a description
CREATE TABLE TestRuns (
    TestRunID INT IDENTITY(1,1) PRIMARY KEY,
    Description NVARCHAR(2000),
    StartAt DATETIME,
    EndAt DATETIME
);

-- for every table used in a test, this table stores how long the insert operation lasted
CREATE TABLE TestRunTables (
    TestRunID INT NOT NULL,
    TableID INT NOT NULL,
    StartAt DATETIME NOT NULL,
    EndAt DATETIME NOT NULL,
    PRIMARY KEY(TestRunID, TableID),
    FOREIGN KEY(TestRunID) REFERENCES TestRuns(TestRunID),
    FOREIGN KEY(TableID) REFERENCES Tables(TableID)
);

-- stores timing information for every view that was executed during a test run
CREATE TABLE TestRunViews (
    TestRunID INT NOT NULL,
    ViewID INT NOT NULL,
    StartAt DATETIME NOT NULL,
    EndAt DATETIME NOT NULL,
    PRIMARY KEY(TestRunID, ViewID),
    FOREIGN KEY(TestRunID) REFERENCES TestRuns(TestRunID),
    FOREIGN KEY(ViewID) REFERENCES Views(ViewID)
);
GO


-- PROCEDURES


-- adds a real database table to the list of tables used in tests
DROP PROCEDURE IF EXISTS addToTables;
GO
CREATE PROCEDURE addToTables @tableName VARCHAR(255)
AS
BEGIN
    -- put a table name in the Tables table
    INSERT INTO Tables(Name)
    VALUES(@tableName);

    PRINT 'Table added: ' + @tableName;
END;
GO

-- adds a view to the list of views used in tests
-- these views will later be executed and timed in runTest()
DROP PROCEDURE IF EXISTS addToViews;
GO
CREATE PROCEDURE addToViews @viewName VARCHAR(255)
AS
BEGIN
    -- register the view in the testing system
    INSERT INTO Views(Name) VALUES(@viewName);

    PRINT 'View added: ' + @viewName;
END;
GO


-- creates a new test name
-- a test represents a group of tables and views that will later be connected and executed together.
DROP PROCEDURE IF EXISTS addToTests;
GO
CREATE PROCEDURE addToTests @testName VARCHAR(255)
AS
BEGIN
    -- store the test name so we can attach tables and views to it
    INSERT INTO Tests(Name) 
    VALUES(@testName);

    PRINT 'Test created: ' + @testName;
END;
GO


-- links a table to a test.
--   @rows = how many rows will be inserted in this table
--   @pos  = the order in which tables will be processed during runTest()
DROP PROCEDURE IF EXISTS connectTableToTest;
GO
CREATE PROCEDURE connectTableToTest 
    @tableName VARCHAR(255), 
    @testName VARCHAR(255), 
    @rows INT, 
    @pos INT
AS
BEGIN
    -- look up the table ID and the test ID
    DECLARE @tid INT  = (SELECT TableID FROM Tables WHERE Name=@tableName);
    DECLARE @testID INT = (SELECT TestID  FROM Tests  WHERE Name=@testName);

    -- store this table as part of the test definition
    INSERT INTO TestTables(TestID, TableID, NoOfRows, Position)
    VALUES(@testID, @tid, @rows, @pos);

    PRINT 'Table linked: ' + @tableName + ' -> ' + @testName;
END;
GO



-- links a view to a test
-- all connected views will be executed and timed in runTest()
DROP PROCEDURE IF EXISTS connectViewToTest;
GO
CREATE PROCEDURE connectViewToTest 
    @viewName VARCHAR(255), 
    @testName VARCHAR(255)
AS
BEGIN
    -- get the IDs
    DECLARE @vid INT = (SELECT ViewID FROM Views WHERE Name=@viewName);
    DECLARE @tid INT = (SELECT TestID FROM Tests WHERE Name=@testName);

    -- store the relationship
    INSERT INTO TestViews(TestID, ViewID)
    VALUES(@tid, @vid);

    PRINT 'View linked: ' + @viewName + ' -> ' + @testName;
END;
GO


-- POPULATE PROCEDURES 


-- inserts a given number of fake teachers into the Teachers table
-- each row gets:
--      FirstName = 'TFirst1', 'TFirst2' ...
--      LastName  = 'TLast1',  'TLast2'  ...
--      TeachingSubject = 'Subject1', 'Subject2' ...
DROP PROCEDURE IF EXISTS populateTable_Teachers;
GO
CREATE PROCEDURE populateTable_Teachers @rows INT
AS
BEGIN
    DECLARE @i INT = 1;

    WHILE @i <= @rows
    BEGIN
        INSERT INTO Teachers(FirstName, LastName, TeachingSubject)
        VALUES(
            'TFirst' + CAST(@i AS VARCHAR),
            'TLast' + CAST(@i AS VARCHAR),
            'Subject' + CAST(@i AS VARCHAR)
        );

        SET @i += 1;
    END
END;
GO



-- inserts a given number of students into the Students table
-- each student receives:
--      FirstName = 'SFirst1', 'SFirst2' ...
--      LastName  = 'SLast1',  'SLast2' ...
--      BirthDate = today minus i days (just to generate variation)
DROP PROCEDURE IF EXISTS populateTable_Students;
GO
CREATE PROCEDURE populateTable_Students @rows INT
AS
BEGIN
    DECLARE @i INT = 1;

    WHILE @i <= @rows
    BEGIN
        INSERT INTO Students(FirstName, LastName, BirthDate)
        VALUES(
            'SFirst' + CAST(@i AS VARCHAR),
            'SLast'  + CAST(@i AS VARCHAR),
            DATEADD(DAY, -@i, GETDATE())
        );

        SET @i += 1;
    END
END;
GO



-- inserts a given number of lessons.
-- lessons require a TeacherID, InstrumentID, and RoomID.
-- we simply use existing IDs (TeacherID = first teacher, etc.) because the test only measures execution time, not data accuracy.
DROP PROCEDURE IF EXISTS populateTable_Lessons;
GO
CREATE PROCEDURE populateTable_Lessons @rows INT
AS
BEGIN
    DECLARE @i INT = 1;

    -- reuse existing IDs (simple approach for testing)
    DECLARE @teacher INT   = (SELECT TOP 1 TeacherID FROM Teachers);
    DECLARE @instrument INT = 1;  -- placeholder
    DECLARE @room INT       = 1;  -- placeholder

    WHILE @i <= @rows
    BEGIN
        INSERT INTO Lessons(LessonName, TeacherID, InstrumentID, RoomID)
        VALUES(
            'Lesson ' + CAST(@i AS VARCHAR),
            @teacher,
            @instrument,
            @room
        );

        SET @i += 1;
    END
END;
GO



-- inserts student–lesson relationships
-- a lesson must exist, so we take the first LessonID available
-- students are assigned starting from student 1 up to @rows
DROP PROCEDURE IF EXISTS populateTable_LessonParticipants;
GO
CREATE PROCEDURE populateTable_LessonParticipants @rows INT
AS
BEGIN
    -- pick an existing lesson (only one is needed for testing)
    DECLARE @lesson INT = (SELECT TOP 1 LessonID FROM Lessons);

    -- number of students available
    DECLARE @students INT = (SELECT COUNT(*) FROM Students);

    DECLARE @i INT = 1;

    WHILE @i <= @rows AND @i <= @students
    BEGIN
        INSERT INTO LessonParticipants(LessonID, StudentID)
        VALUES(@lesson, @i);

        SET @i += 1;
    END
END;
GO


-- VIEWS 


-- view that shows basic teacher information
DROP VIEW IF EXISTS View_Teachers;
GO
CREATE VIEW View_Teachers AS
SELECT 
    TeacherID,
    FirstName,
    LastName,
    TeachingSubject
FROM Teachers;
GO



-- view joins two tables: Lessons and Teachers
-- it shows each lesson together with the teacher who teaches it
DROP VIEW IF EXISTS View_LessonDetails;
GO
CREATE VIEW View_LessonDetails AS
SELECT 
    L.LessonID,
    L.LessonName,
    T.FirstName AS TeacherFirst,
    T.LastName  AS TeacherLast
FROM Lessons L
JOIN Teachers T 
    ON L.TeacherID = T.TeacherID;
GO


-- view shows how many students participate in each lesson -> one row per lesson with the number of enrolled students.
DROP VIEW IF EXISTS View_StudentsPerLesson;
GO
CREATE VIEW View_StudentsPerLesson AS
SELECT 
    LessonID,
    COUNT(*) AS NumStudents
FROM LessonParticipants
GROUP BY LessonID;
GO

-- runTest 

-- runs a test by:
--   1) disabling all foreign key constraints so tables can be cleaned safely
--   2) deleting all data from the tables that belong to the test (in ASC order)
--   3) inserting new test data into those tables using their populate procedures (in DESC order)
--   4) executing every view linked to the test and measuring execution time
--   5) storing timing information for both table inserts and view executions
--   6) re-enabling all foreign key constraints after the test finishes
--   7) saving the final end timestamp for the test run
DROP PROCEDURE IF EXISTS runTest;
GO

CREATE PROCEDURE runTest @testName VARCHAR(255), @descr VARCHAR(255)
AS
BEGIN
    -- get the ID of the test we want to run
    DECLARE @testID INT = (SELECT TestID FROM Tests WHERE Name=@testName);
    IF @testID IS NULL BEGIN PRINT 'Test not found'; RETURN; END;

    -- disable all FK constraints so DELETE operations cannot fail
    ALTER TABLE LessonParticipants      NOCHECK CONSTRAINT ALL;
    ALTER TABLE Lessons                 NOCHECK CONSTRAINT ALL;
    ALTER TABLE Students                NOCHECK CONSTRAINT ALL;
    ALTER TABLE Teachers                NOCHECK CONSTRAINT ALL;
    ALTER TABLE InstrumentRentals       NOCHECK CONSTRAINT ALL;
    ALTER TABLE Schedules               NOCHECK CONSTRAINT ALL;
    ALTER TABLE Grades                  NOCHECK CONSTRAINT ALL;
    ALTER TABLE PerformanceParticipants NOCHECK CONSTRAINT ALL;
    ALTER TABLE StudentLessons          NOCHECK CONSTRAINT ALL;

    -- create a new test run entry
    INSERT INTO TestRuns(Description, StartAt, EndAt)
    VALUES(@descr, SYSDATETIME(), SYSDATETIME());

    DECLARE @runID INT = SCOPE_IDENTITY();   -- ID of the new test run


    -- DELETE existing data from all tables linked to the test (children first)
    DECLARE @table NVARCHAR(100), @tid INT, @rows INT;
    DECLARE @delCmd NVARCHAR(400);

    DECLARE deleteCursor CURSOR FOR
        SELECT T.Name, T.TableID, TT.NoOfRows
        FROM Tables T
        JOIN TestTables TT ON T.TableID = TT.TableID
        WHERE TT.TestID = @testID
        ORDER BY TT.Position ASC;       -- delete in dependency order

    OPEN deleteCursor;
    FETCH NEXT FROM deleteCursor INTO @table, @tid, @rows;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @delCmd = N'DELETE FROM ' + QUOTENAME(@table);
        EXEC(@delCmd);

        FETCH NEXT FROM deleteCursor INTO @table, @tid, @rows;
    END

    CLOSE deleteCursor;
    DEALLOCATE deleteCursor;


    -- INSERT new rows into all tables (parents first)
    DECLARE @cmd NVARCHAR(400);

    DECLARE insertCursor CURSOR FOR
        SELECT T.Name, T.TableID, TT.NoOfRows
        FROM Tables T
        JOIN TestTables TT ON T.TableID = TT.TableID
        WHERE TT.TestID = @testID
        ORDER BY TT.Position DESC;     -- insert in reverse order

    OPEN insertCursor;
    FETCH NEXT FROM insertCursor INTO @table, @tid, @rows;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- call the correct population procedure dynamically
        SET @cmd = N'EXEC populateTable_' + @table + N' ' + CAST(@rows AS NVARCHAR);

        DECLARE @s DATETIME = SYSDATETIME();
        EXEC(@cmd);
        DECLARE @e DATETIME = SYSDATETIME();

        -- store timing information
        INSERT INTO TestRunTables VALUES(@runID, @tid, @s, @e);

        FETCH NEXT FROM insertCursor INTO @table, @tid, @rows;
    END

    CLOSE insertCursor;
    DEALLOCATE insertCursor;


    -- execute each view linked to the test and measure runtime
    DECLARE @view NVARCHAR(100), @vid INT, @viewCmd NVARCHAR(400);

    DECLARE viewCursor CURSOR FOR
        SELECT V.Name, V.ViewID
        FROM Views V
        JOIN TestViews TV ON V.ViewID = TV.ViewID
        WHERE TV.TestID = @testID;

    OPEN viewCursor;
    FETCH NEXT FROM viewCursor INTO @view, @vid;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @viewCmd = N'SELECT * FROM ' + QUOTENAME(@view);

        DECLARE @sv DATETIME = SYSDATETIME();
        EXEC(@viewCmd);
        DECLARE @ev DATETIME = SYSDATETIME();

        INSERT INTO TestRunViews VALUES(@runID, @vid, @sv, @ev);

        FETCH NEXT FROM viewCursor INTO @view, @vid;
    END

    CLOSE viewCursor;
    DEALLOCATE viewCursor;


    -- re-enable all FK constraints
    ALTER TABLE LessonParticipants      CHECK CONSTRAINT ALL;
    ALTER TABLE Lessons                 CHECK CONSTRAINT ALL;
    ALTER TABLE Students                CHECK CONSTRAINT ALL;
    ALTER TABLE Teachers                CHECK CONSTRAINT ALL;
    ALTER TABLE InstrumentRentals       CHECK CONSTRAINT ALL;
    ALTER TABLE Schedules               CHECK CONSTRAINT ALL;
    ALTER TABLE Grades                  CHECK CONSTRAINT ALL;
    ALTER TABLE PerformanceParticipants CHECK CONSTRAINT ALL;
    ALTER TABLE StudentLessons          CHECK CONSTRAINT ALL;

    -- mark the test run as finished
    UPDATE TestRuns 
    SET EndAt = SYSDATETIME()
    WHERE TestRunID = @runID;
END;
GO



EXEC addToTables 'Teachers';
EXEC addToTables 'Students';
EXEC addToTables 'Lessons';
EXEC addToTables 'LessonParticipants';

EXEC addToViews 'View_Teachers';
EXEC addToViews 'View_LessonDetails';
EXEC addToViews 'View_StudentsPerLesson';

EXEC addToTests 'MainTest';

EXEC connectTableToTest 'LessonParticipants', 'MainTest', 10, 1;
EXEC connectTableToTest 'Lessons',            'MainTest', 10, 2;
EXEC connectTableToTest 'Students',           'MainTest', 20, 3;
EXEC connectTableToTest 'Teachers',           'MainTest', 10, 4;

EXEC connectViewToTest 'View_Teachers', 'MainTest';
EXEC connectViewToTest 'View_LessonDetails', 'MainTest';
EXEC connectViewToTest 'View_StudentsPerLesson', 'MainTest';

EXEC runTest 'MainTest', 'First Test Run';
GO

SELECT * FROM TestRuns;
SELECT * FROM TestRunTables;
SELECT * FROM TestRunViews;
