USE MusicSchool
GO

-- DEADLOCK
-- T1 locks Students row 1 then requests Teachers row 1.
-- T2 locks Teachers row 1 then requests Students row 1.
-- Each transaction holds what the other needs => deadlock cycle.
-- SQL Server detects the cycle and kills one transaction as the victim (error 1205).

-- A1
-- fix: always lock tables in the same order (Students before Teachers) in every transaction
BEGIN TRANSACTION
    UPDATE Students
    SET FirstName = FirstName
    WHERE StudentID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('Deadlock_T1', 'Info',
           'T1: Locked Students row StudentID=1.')

-- B1
BEGIN TRANSACTION
    UPDATE Teachers
    SET FirstName = FirstName
    WHERE TeacherID = 1

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('Deadlock_T2', 'Info',
           'T2: Locked Teachers row TeacherID=1.')

-- A2
    UPDATE Teachers
    SET FirstName = FirstName
    WHERE TeacherID = 1
    -- T1 blocks here waiting for T2 to release Teachers row

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('Deadlock_T1', 'Info',
           'T1: Acquired Teachers row TeacherID=1 (T1 survived the deadlock).')
COMMIT TRANSACTION

-- B2
    UPDATE Students
    SET FirstName = FirstName
    WHERE StudentID = 1
    -- deadlock cycle forms here; SQL Server kills one transaction (error 1205)

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('Deadlock_T2', 'Info',
           'T2: Acquired Students row StudentID=1 (T2 survived the deadlock).')
COMMIT TRANSACTION

SELECT * FROM Students WHERE StudentID = 1
SELECT * FROM Teachers WHERE TeacherID = 1
SELECT * FROM Logs ORDER BY LogID DESC


-- solution : consistent lock ordering
-- always lock Students before Teachers in every transaction
-- if every transaction acquires locks in the same order, no cycle can ever form

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

-- [T1] run in window 1:
EXEC sp_UpdateStudentAndTeacher
    @studentID = 1,
    @teacherID = 1

-- [T2] run in window 2 at the same time:
EXEC sp_UpdateStudentAndTeacher
    @studentID = 1,
    @teacherID = 1

SELECT * FROM Students WHERE StudentID = 1
SELECT * FROM Teachers WHERE TeacherID = 1
SELECT * FROM Logs ORDER BY LogID DESC