USE MusicSchool
GO

-- 1. T1 : lock Students row 1, hold it for 30 seconds, then request Teachers row 1.
BEGIN TRANSACTION
UPDATE Students
SET FirstName = FirstName
WHERE StudentID = 1

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('Deadlock_T1', 'Info',
        'T1: Locked Students row StudentID=1. Holding for 30s before requesting Teachers row.')

WAITFOR DELAY '00:00:30'  -- holds the lock while T2 acquires its own lock

UPDATE Teachers
SET FirstName = FirstName
WHERE TeacherID = 1

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('Deadlock_T1', 'Info',
        'T1: Acquired Teachers row TeacherID=1 (T1 survived the deadlock).')
COMMIT TRANSACTION


-- 2. T2 : lock Teachers row 1, hold it for 30 seconds, then request Students row 1.
--    After both delays expire, both transactions request each other's locked row
--    => deadlock cycle forms => SQL Server kills one as the victim (error 1205).
BEGIN TRANSACTION
UPDATE Teachers
SET FirstName = FirstName
WHERE TeacherID = 1

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('Deadlock_T2', 'Info',
        'T2: Locked Teachers row TeacherID=1. Holding for 30s before requesting Students row.')

WAITFOR DELAY '00:00:30'  -- holds the lock while T1 requests this row

UPDATE Students
SET FirstName = FirstName
WHERE StudentID = 1

INSERT INTO Logs(ActionName, Status, ErrorMessage)
VALUES('Deadlock_T2', 'Info',
        'T2: Acquired Students row StudentID=1 (T2 survived the deadlock).')
COMMIT TRANSACTION

SELECT * FROM Logs ORDER BY LogID DESC

-- solution : consistent lock ordering:
--   Always access tables in the same order in every transaction.
--   If every transaction always locks Students before Teachers,
--   no cycle can ever form.

IF OBJECT_ID('sp_UpdateStudentAndTeacher', 'P') IS NOT NULL DROP PROCEDURE sp_UpdateStudentAndTeacher
GO

CREATE PROCEDURE sp_UpdateStudentAndTeacher
@studentID  INT,
@teacherID  INT
AS
BEGIN
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION
        UPDATE Students
        SET FirstName = FirstName
        WHERE StudentID = @studentID

        UPDATE Teachers
        SET FirstName = FirstName
        WHERE TeacherID = @teacherID

        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('Deadlock_Solution', 'Success',
                'sp_UpdateStudentAndTeacher: Updated rows in consistent order - no deadlock.')
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('Deadlock_Solution', 'Error', ERROR_MESSAGE())
    RAISERROR('Error in sp_UpdateStudentAndTeacher. See Logs.', 16, 1)
END CATCH
END
GO


EXEC sp_UpdateStudentAndTeacher
@studentID = 1,
@teacherID = 1

EXEC sp_UpdateStudentAndTeacher
@studentID = 1,
@teacherID = 1

SELECT * FROM Logs ORDER BY LogID DESC
