USE Music_School
GO


DROP PROCEDURE IF EXISTS do_proc_1;
DROP PROCEDURE IF EXISTS undo_proc_1;
DROP PROCEDURE IF EXISTS do_proc_2;
DROP PROCEDURE IF EXISTS undo_proc_2;
DROP PROCEDURE IF EXISTS do_proc_3;
DROP PROCEDURE IF EXISTS undo_proc_3;
DROP PROCEDURE IF EXISTS do_proc_4;
DROP PROCEDURE IF EXISTS undo_proc_4;
DROP PROCEDURE IF EXISTS do_proc_5;
DROP PROCEDURE IF EXISTS undo_proc_5;
DROP PROCEDURE IF EXISTS do_proc_6;
DROP PROCEDURE IF EXISTS undo_proc_6;
DROP PROCEDURE IF EXISTS do_proc_7;
DROP PROCEDURE IF EXISTS undo_proc_7;
DROP PROCEDURE IF EXISTS goToVersion;

DROP TABLE IF EXISTS EventTypes;
DROP TABLE IF EXISTS PrimaryKeyTable;

DROP TABLE IF EXISTS VersionTable;
DROP TABLE IF EXISTS Procedures_Table;
GO


-- 1) Modify the type of a column
CREATE PROCEDURE do_proc_1 AS
BEGIN
    ALTER TABLE Students ALTER COLUMN FirstName VARCHAR(100);
END;
GO

-- 2) Modify the type of a column BACK
CREATE PROCEDURE undo_proc_1 AS
BEGIN
    ALTER TABLE Students ALTER COLUMN FirstName VARCHAR(50);
END;
GO


-- 3) Add a new column
CREATE PROCEDURE do_proc_2 AS
    ALTER TABLE Students ADD Email VARCHAR(100);
GO

-- 4) Delete a column
CREATE PROCEDURE undo_proc_2 AS
    ALTER TABLE Students DROP COLUMN Email;
GO


-- 5) Add default constraint
CREATE PROCEDURE do_proc_3 AS
    ALTER TABLE Rooms ADD CONSTRAINT DefaultRoomCapacity DEFAULT 20 FOR Capacity;
GO

-- 6) Remove default constraint
CREATE PROCEDURE undo_proc_3 AS
    ALTER TABLE Rooms DROP CONSTRAINT DefaultRoomCapacity;
GO

-- 7) Create table
CREATE PROCEDURE do_proc_4 AS
    CREATE TABLE EventTypes(
        EventTypeID INT NOT NULL,
        Name VARCHAR(100)
    )
GO

-- 8) Remove table
CREATE PROCEDURE undo_proc_4 AS
    EXEC('DROP TABLE EventTypes');
GO


-- 9) Create a primary key

CREATE PROCEDURE do_proc_5 AS
    ALTER TABLE EventTypes ADD CONSTRAINT PK_EventTypes PRIMARY KEY (EventTypeID);
GO

-- 10) Remove primary key
CREATE PROCEDURE undo_proc_5 AS
    ALTER TABLE EventTypes DROP CONSTRAINT PK_EventTypes;
GO


-- 11) Create a candidate key
CREATE PROCEDURE do_proc_6 AS
    ALTER TABLE Teachers ADD CONSTRAINT CandidateKeyTeacherName UNIQUE(FirstName, LastName);
GO

-- 12) Remove candidate key
CREATE PROCEDURE undo_proc_6 AS
    ALTER TABLE Teachers DROP CONSTRAINT CandidateKeyTeacherName;
GO


-- 13) Add a foreign key constraint
CREATE PROCEDURE do_proc_7 AS
    ALTER TABLE StudentLessons ADD CONSTRAINT FK_StudentLessons_Student2 FOREIGN KEY(StudentID) REFERENCES Students(StudentID);
GO

-- 14) Remove a foreign key constraint
CREATE PROCEDURE undo_proc_7 AS
    ALTER TABLE StudentLessons DROP CONSTRAINT FK_StudentLessons_Student2;
GO


CREATE TABLE VersionTable(
    Version INT PRIMARY KEY
);
INSERT INTO VersionTable VALUES (0);
GO


CREATE TABLE Procedures_Table(
    fromVersion INT,
    toVersion INT,
    nameProc VARCHAR(100),
    PRIMARY KEY (fromVersion, toVersion)
);
GO

INSERT INTO Procedures_Table VALUES (0, 1, 'do_proc_1');
INSERT INTO Procedures_Table VALUES (1, 2, 'do_proc_2');
INSERT INTO Procedures_Table VALUES (2, 3, 'do_proc_3');
INSERT INTO Procedures_Table VALUES (3, 4, 'do_proc_4');
INSERT INTO Procedures_Table VALUES (4, 5, 'do_proc_5');
INSERT INTO Procedures_Table VALUES (5, 6, 'do_proc_6');
INSERT INTO Procedures_Table VALUES (6, 7, 'do_proc_7');

INSERT INTO Procedures_Table VALUES (1, 0, 'undo_proc_1');
INSERT INTO Procedures_Table VALUES (2, 1, 'undo_proc_2');
INSERT INTO Procedures_Table VALUES (3, 2, 'undo_proc_3');
INSERT INTO Procedures_Table VALUES (4, 3, 'undo_proc_4');
INSERT INTO Procedures_Table VALUES (5, 4, 'undo_proc_5');
INSERT INTO Procedures_Table VALUES (6, 5, 'undo_proc_6');
INSERT INTO Procedures_Table VALUES (7, 6, 'undo_proc_7');
GO


CREATE PROCEDURE goToVersion @newVersion INT AS
BEGIN
    DECLARE @currentVersion INT;
    DECLARE @procName VARCHAR(100);

    -- read current version
    SELECT @currentVersion = Version FROM VersionTable;

    -- validate parameter
    IF @newVersion > (SELECT MAX(toVersion) FROM Procedures_Table)
    BEGIN
        RAISERROR('Invalid version', 10, 1);
        RETURN;
    END

    IF @currentVersion = @newVersion
    BEGIN
        PRINT 'Database is already at version ' + CAST(@currentVersion AS VARCHAR(10));
        RETURN;
    END

    -- downgrade
    WHILE @currentVersion > @newVersion
    BEGIN
        SELECT @procName = nameProc
        FROM Procedures_Table
        WHERE fromVersion = @currentVersion
          AND toVersion = @currentVersion - 1;

        EXEC(@procName);

        SET @currentVersion = @currentVersion - 1;
    END

    -- upgrade
    WHILE @currentVersion < @newVersion
    BEGIN
        SELECT @procName = nameProc
        FROM Procedures_Table
        WHERE fromVersion = @currentVersion
          AND toVersion = @currentVersion + 1;

        EXEC(@procName);

        SET @currentVersion = @currentVersion + 1;
    END

    -- update version table
    UPDATE VersionTable SET Version = @newVersion;
END;
GO


EXEC goToVersion 7;
SELECT * FROM VersionTable;

EXEC goToVersion 3;
SELECT * FROM VersionTable;

EXEC goToVersion 0;
SELECT * FROM VersionTable;