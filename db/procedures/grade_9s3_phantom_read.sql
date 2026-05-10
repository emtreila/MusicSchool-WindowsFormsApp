USE MusicSchool
GO

-- 1. T1 : first range query under REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
DECLARE @countFirst INT
SELECT @countFirst = COUNT(*)
FROM Grades
WHERE GradeValue >= 9

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('PhantomRead_T1', 'Info',
        'T1: First query - found ' + CAST(@countFirst AS VARCHAR) +
        ' grades >= 9.')

-- 2. T2 : Insert a new row that satisfies the predicate and commit.
--    REPEATABLE READ does not block inserts into the range, only updates/deletes of already-read rows.
BEGIN TRANSACTION
INSERT INTO Grades(StudentID, LessonID, GradeValue)
VALUES (1, 2, 10)   -- new row satisfying GradeValue >= 9

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('PhantomRead_T2', 'Info',
        'T2: Inserted a new grade of 10 for StudentID=1, LessonID=2 and committed.')
COMMIT TRANSACTION

-- 3. T1 : second range query - count is higher now (the phantom row appeared)
DECLARE @countSecond INT
SELECT @countSecond = COUNT(*)
FROM Grades
WHERE GradeValue >= 9

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('PhantomRead_T1', 'Info',
        'T1: Second query - found ' + CAST(@countSecond AS VARCHAR) +
        ' grades >= 9 (was ' + CAST(@countFirst AS VARCHAR) +
        ') - phantom read demonstrated.')
COMMIT TRANSACTION
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

-- clean up the inserted phantom row
DELETE FROM Grades WHERE StudentID = 1 AND LessonID = 2 AND GradeValue = 10

SELECT * FROM Logs ORDER BY LogID DESC


-- solution : use SERIALIZABLE.
-- SQL Server acquires a range lock on the predicate GradeValue >= 9,
-- preventing T2 from inserting any row satisfying that condition
-- until T1 commits. Both queries by T1 return the same row count.

-- 1. T1 : first range query under SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
BEGIN TRANSACTION
DECLARE @countFirstSol INT
SELECT @countFirstSol = COUNT(*)
FROM Grades
WHERE GradeValue >= 9

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('PhantomRead_Solution_T1', 'Info',
        'T1 (solution): First query - found ' + CAST(@countFirstSol AS VARCHAR) +
        ' grades >= 9.')

-- 2. T2 : T2 tries to insert a row satisfying the predicate.
--    It will BLOCK because T1 holds a range lock under SERIALIZABLE.
BEGIN TRANSACTION
INSERT INTO Grades(StudentID, LessonID, GradeValue)
VALUES (1, 2, 10)
-- blocks until T1 commits

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('PhantomRead_Solution_T2', 'Info',
        'T2 (solution): Insert committed after T1 released its range lock.')
COMMIT TRANSACTION


-- 3. T1 : second range query - same count as the first. T2 was blocked so no new rows entered the range.
DECLARE @countSecondSol INT
SELECT @countSecondSol = COUNT(*)
FROM Grades
WHERE GradeValue >= 9

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('PhantomRead_Solution_T1', 'Info',
        'T1 (solution): Second query - found ' + CAST(@countSecondSol AS VARCHAR) +
        ' grades >= 9 - same as first, no phantom read.')
COMMIT TRANSACTION
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

-- clean up (only runs if T2 committed, i.e. after T1 committed above)
DELETE FROM Grades WHERE StudentID = 1 AND LessonID = 2 AND GradeValue = 10

SELECT * FROM Logs ORDER BY LogID DESC
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
SET TRANSACTION ISOLATION LEVEL READ COMMITTED