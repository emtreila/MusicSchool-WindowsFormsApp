USE MusicSchool
GO

-- 1. T1 : first read inside the transaction and leave T1 open
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
DECLARE @firstRead INT
SELECT @firstRead = GradeValue
FROM Grades
WHERE StudentID = 1 AND LessonID = 1

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('NonRepeatableRead_T1', 'Info',
        'T1: First read - GradeValue = ' + CAST(@firstRead AS VARCHAR) +
        ' for StudentID=1, LessonID=1.')

-- 2. T2 : update the same row and commit. T1 is still open but READ COMMITTED does not block T2 here.
BEGIN TRANSACTION
UPDATE Grades
SET GradeValue = 5
WHERE StudentID = 1 AND LessonID = 1

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('NonRepeatableRead_T2', 'Info',
        'T2: Updated GradeValue to 5 for StudentID=1, LessonID=1 and committed.')
COMMIT TRANSACTION


-- 3. T1 : second read within the same transaction returns 5 instead of the original value
DECLARE @secondRead INT
SELECT @secondRead = GradeValue
FROM Grades
WHERE StudentID = 1 AND LessonID = 1

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('NonRepeatableRead_T1', 'Info',
        'T1: Second read - GradeValue = ' + CAST(@secondRead AS VARCHAR) +
        ' (was ' + CAST(@firstRead AS VARCHAR) + ') - non-repeatable read demonstrated.')
COMMIT TRANSACTION
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
-- restore the original value
UPDATE Grades SET GradeValue = 9 WHERE StudentID = 1 AND LessonID = 1

SELECT * FROM Logs ORDER BY LogID DESC


-- solution : Use REPEATABLE READ or higher.
-- The shared lock acquired by T1's first read is held until T1'stransaction ends. 
-- T2's UPDATE on that row will block until T1 commits. Both reads by T1 will return the same value.

-- 1. T1 : first read under REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
DECLARE @firstReadSol INT
SELECT @firstReadSol = GradeValue
FROM Grades
WHERE StudentID = 1 AND LessonID = 1

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('NonRepeatableRead_Solution_T1', 'Info',
        'T1 (solution): First read - GradeValue = ' + CAST(@firstReadSol AS VARCHAR) + '.')


-- 2. T2 : T2 tries to update the same row, but it will BLOCK because T1 holds a shared lock under REPEATABLE READ.
BEGIN TRANSACTION
UPDATE Grades
SET GradeValue = 5
WHERE StudentID = 1 AND LessonID = 1
-- blocks until T1 commits

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('NonRepeatableRead_Solution_T2', 'Info',
        'T2 (solution): Update committed after T1 released its shared lock.')
COMMIT TRANSACTION


-- 3. T1 : second read - returns the same value as the first. T2 was blocked, so nothing changed between the two reads.
DECLARE @secondReadSol INT
SELECT @secondReadSol = GradeValue
FROM Grades
WHERE StudentID = 1 AND LessonID = 1

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('NonRepeatableRead_Solution_T1', 'Info',
        'T1 (solution): Second read - GradeValue = ' + CAST(@secondReadSol AS VARCHAR) +
        ' - same as first read, no non-repeatable read.')
COMMIT TRANSACTION
SET TRANSACTION ISOLATION LEVEL READ COMMITTED

-- restore the original value
UPDATE Grades SET GradeValue = 9 WHERE StudentID = 1 AND LessonID = 1

SELECT * FROM Logs ORDER BY LogID DESC