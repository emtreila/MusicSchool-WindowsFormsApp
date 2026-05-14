USE MusicSchool
GO

-- PHANTOM READ
-- T1 runs the same range query twice within the same transaction.
-- Between the two queries, T2 inserts a new row satisfying the predicate and commits.
-- T1's second query returns more rows than the first - the new row is the phantom.
-- REPEATABLE READ does not block inserts into the range, only updates/deletes of already-read rows.

-- A1
-- fix: SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ
BEGIN TRANSACTION
    SELECT StudentID, LessonID, GradeValue
    FROM Grades
    WHERE GradeValue >= 9

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('PhantomRead_T1', 'Info',
           'T1: First query - grades >= 9.')

-- B
BEGIN TRANSACTION
    INSERT INTO Grades(StudentID, LessonID, GradeValue)
    VALUES (1, 2, 10)  -- new row satisfying GradeValue >= 9

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('PhantomRead_T2', 'Info',
           'T2: Inserted a new grade of 10 for StudentID=1, LessonID=2 and committed.')
COMMIT TRANSACTION

-- A2
    SELECT StudentID, LessonID, GradeValue
    FROM Grades
    WHERE GradeValue >= 9

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('PhantomRead_T1', 'Info',
           'T1: Second query - more rows than first - phantom read demonstrated.')
COMMIT TRANSACTION

-- clean up
DELETE FROM Grades WHERE StudentID = 1 AND LessonID = 2 AND GradeValue = 10

SELECT * FROM Grades WHERE GradeValue >= 9
SELECT * FROM Logs ORDER BY LogID DESC