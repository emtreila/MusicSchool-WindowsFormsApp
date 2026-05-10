USE MusicSchool
GO

-- 1. T1: start a transaction and update a grade, but don't commit yet
BEGIN TRANSACTION
    UPDATE Grades
    SET GradeValue = 1
    WHERE StudentID = 1 AND LessonID = 1   -- original value is 9

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('DirtyRead_T1', 'Info',
           'T1: Updated GradeValue to 1 for StudentID=1, LessonID=1 - not committed yet.')

SELECT * FROM Logs ORDER BY LogID DESC
SELECT * FROM Grades G WHERE G.StudentID = 1 AND G.LessonID = 1

-- 2. T2 : read the grade under READ UNCOMMITTED. -> T2 will see the dirty value 1, even though T1 didn't commit
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION
    DECLARE @dirtyGrade INT
    SELECT @dirtyGrade = GradeValue
    FROM Grades
    WHERE StudentID = 1 AND LessonID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('DirtyRead_T2', 'Info',
           'T2: Read GradeValue = ' + CAST(@dirtyGrade AS VARCHAR) +
           ' for StudentID=1, LessonID=1 (dirty read - T1 not committed yet).')
COMMIT TRANSACTION
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

SELECT * FROM Logs ORDER BY LogID DESC
SELECT * FROM Grades G WHERE G.StudentID = 1 AND G.LessonID = 1

-- 3. T1 : roll back T1. The value 1 never actually existed in the database.
--    T2 already read it -> that is the dirty read.
ROLLBACK TRANSACTION

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('DirtyRead_T1', 'Rollback',
       'T1: Rolled back. The dirty value 1 read by T2 never existed.')

SELECT * FROM Logs ORDER BY LogID DESC
SELECT * FROM Grades G WHERE G.StudentID = 1 AND G.LessonID = 1


-- solution : use READ COMMITTED
-- T2 will block on its SELECT until T1 either commits or rolls back, so it can never see uncommitted data.

-- 1. T1 : same update, not committed yet.
BEGIN TRANSACTION
    UPDATE Grades
    SET GradeValue = 1
    WHERE StudentID = 1 AND LessonID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('DirtyRead_Solution_T1', 'Info',
           'T1 (solution): Updated GradeValue to 1 - not committed yet.')

SELECT * FROM Logs ORDER BY LogID DESC
SELECT * FROM Grades G WHERE G.StudentID = 1 AND G.LessonID = 1

-- 2. T2 : the SELECT will block until T1 finishes 
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
    DECLARE @cleanGrade INT
    SELECT @cleanGrade = GradeValue
    FROM Grades
    WHERE StudentID = 1 AND LessonID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('DirtyRead_Solution_T2', 'Info',
           'T2 (solution): Read GradeValue = ' + CAST(@cleanGrade AS VARCHAR) +
           ' - only committed data, no dirty read.')
COMMIT TRANSACTION

SELECT * FROM Logs ORDER BY LogID DESC
SELECT * FROM Grades G WHERE G.StudentID = 1 AND G.LessonID = 1

-- 3. T1 : roll back -> T2 was blocking, so it now reads the original value 9.
ROLLBACK TRANSACTION

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('DirtyRead_Solution_T1', 'Rollback',
       'T1 (solution): Rolled back. T2 unblocked and read the original committed value.')

SELECT * FROM Logs ORDER BY LogID DESC
SELECT * FROM Grades G WHERE G.StudentID = 1 AND G.LessonID = 1