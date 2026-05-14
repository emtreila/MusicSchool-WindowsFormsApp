USE MusicSchool
GO

-- run once to enable SNAPSHOT isolation
ALTER DATABASE MusicSchool SET ALLOW_SNAPSHOT_ISOLATION ON
GO

-- UPDATE CONFLICT UNDER SNAPSHOT ISOLATION
-- T1 starts a SNAPSHOT transaction and reads a grade.
-- T2 updates the same row and commits.
-- T1 tries to update the same row and commit.
-- SQL Server detects that the row was already modified by T2 since T1's snapshot was taken.
-- T1 is aborted with error 3960 - update conflict.
-- Unlike pessimistic isolation, no blocking occurs at any point.
-- The conflict is only detected at T1's commit time.

--A1
SET TRANSACTION ISOLATION LEVEL SNAPSHOT
BEGIN TRANSACTION
    SELECT StudentID, LessonID, GradeValue
    FROM Grades
    WHERE StudentID = 1 AND LessonID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('UpdateConflict_T1', 'Info',
           'T1: Read grade for StudentID=1, LessonID=1. Snapshot taken at this point.')

--B1
BEGIN TRANSACTION
    UPDATE Grades
    SET GradeValue = 6
    WHERE StudentID = 1 AND LessonID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('UpdateConflict_T2', 'Info',
           'T2: Updated GradeValue to 6 and committed.')
COMMIT TRANSACTION

--A2
UPDATE Grades
SET GradeValue = 3
WHERE StudentID = 1 AND LessonID = 1
COMMIT TRANSACTION

SELECT * FROM Grades WHERE StudentID = 1 AND LessonID = 1
SELECT * FROM Logs ORDER BY LogID DESC

-- restore
UPDATE Grades SET GradeValue = 9 WHERE StudentID = 1 AND LessonID = 1


-- solution : retry loop
-- SNAPSHOT aborts the conflicting transaction instead of blocking it.
-- catch error 3960 and retry: re-read the latest committed value and attempt the update again.