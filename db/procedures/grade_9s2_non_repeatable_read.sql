USE MusicSchool
GO

-- NON-REPEATABLE READ
-- T1 reads the same row twice within the same transaction.
-- Between the two reads, T2 updates and commits that row.
-- T1's second read returns a different value than the first.

-- A1
-- fix: SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN TRANSACTION
    SELECT StudentID, LessonID, GradeValue
    FROM Grades
    WHERE StudentID = 1 AND LessonID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('NonRepeatableRead_T1', 'Info',
           'T1: First read - GradeValue for StudentID=1, LessonID=1.')

-- B
BEGIN TRANSACTION
    UPDATE Grades
    SET GradeValue = 5
    WHERE StudentID = 1 AND LessonID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('NonRepeatableRead_T2', 'Info',
           'T2: Updated GradeValue to 5 and committed.')
COMMIT TRANSACTION

-- A2
    SELECT StudentID, LessonID, GradeValue
    FROM Grades
    WHERE StudentID = 1 AND LessonID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('NonRepeatableRead_T1', 'Info',
           'T1: Second read - GradeValue changed - non-repeatable read demonstrated.')
COMMIT TRANSACTION

-- restore
UPDATE Grades SET GradeValue = 9 WHERE StudentID = 1 AND LessonID = 1

SELECT * FROM Grades WHERE StudentID = 1 AND LessonID = 1
SELECT * FROM Logs ORDER BY LogID DESC