USE MusicSchool
GO

-- DIRTY READ
-- T1 updates a grade but does not commit.
-- T2 reads the uncommitted value under READ UNCOMMITTED.
-- T1 rolls back -> T2 read a value that never existed.

-- A1
BEGIN TRANSACTION
    UPDATE Grades
    SET GradeValue = 1
    WHERE StudentID = 1 AND LessonID = 1  -- original value is 9

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('DirtyRead_T1', 'Info',
           'T1: Updated GradeValue to 1 - not committed yet.')

-- B1
-- fix: SET TRANSACTION ISOLATION LEVEL READ COMMITTED
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION
    DECLARE @dirtyGrade INT
    SELECT @dirtyGrade = GradeValue
    FROM Grades
    WHERE StudentID = 1 AND LessonID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('DirtyRead_T2', 'Info',
           'T2: Read GradeValue = ' + CAST(@dirtyGrade AS VARCHAR) +
           ' (dirty read - T1 not committed yet).')
COMMIT TRANSACTION

SELECT * FROM Grades WHERE StudentID = 1 AND LessonID = 1
SELECT * FROM Logs ORDER BY LogID DESC

-- A2
ROLLBACK TRANSACTION

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('DirtyRead_T1', 'Rollback',
       'T1: Rolled back. The dirty value 1 read by T2 never existed.')

-- B2
SELECT * FROM Grades WHERE StudentID = 1 AND LessonID = 1
SELECT * FROM Logs ORDER BY LogID DESC