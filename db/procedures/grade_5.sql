USE MusicSchool

IF OBJECT_ID('sp_EnrollStudentInLesson_PartialRecovery', 'P') IS NOT NULL DROP PROCEDURE sp_EnrollStudentInLesson_PartialRecovery
GO

CREATE PROCEDURE sp_EnrollStudentInLesson_PartialRecovery
    @studentFirstName VARCHAR(50),
    @studentLastName  VARCHAR(50),
    @birthDate        DATE,
    @lessonName       VARCHAR(100),
    @teacherLastName  VARCHAR(50),
    @instrumentName   VARCHAR(50),
    @roomName         VARCHAR(100),
    @status           VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- validation
    IF @status NOT IN ('Active', 'Completed', 'Dropped')
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_PartialRecovery', 'Error',
               'Status must be Active, Completed, or Dropped.')
        RAISERROR('Status must be Active, Completed, or Dropped.', 16, 1)
        RETURN
    END

    DECLARE @newStudentID  INT = NULL
    DECLARE @newLessonID   INT = NULL
    DECLARE @studentOK     BIT = 0
    DECLARE @lessonOK      BIT = 0

    -- try to insert a student
    BEGIN TRY
        EXEC sp_AddStudent
            @studentFirstName = @studentFirstName,
            @studentLastName  = @studentLastName,
            @birthDate        = @birthDate,
            @newStudentID     = @newStudentID OUTPUT

        SET @studentOK = 1

        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_PartialRecovery', 'Success',
               'Student inserted and committed: ' + @studentFirstName + ' ' + @studentLastName)
    END TRY
    BEGIN CATCH
        SET @studentOK = 0

        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_PartialRecovery', 'Error',
               'Failed to insert Student: ' + ERROR_MESSAGE())
    END CATCH

    -- try to insert a lesson
    BEGIN TRY
        EXEC sp_AddLesson
            @lessonName      = @lessonName,
            @teacherLastName = @teacherLastName,
            @instrumentName  = @instrumentName,
            @roomName        = @roomName,
            @newLessonID     = @newLessonID OUTPUT

        SET @lessonOK = 1

        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_PartialRecovery', 'Success',
               'Lesson inserted and committed: ' + @lessonName)
    END TRY
    BEGIN CATCH
        SET @lessonOK = 0

        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_PartialRecovery', 'Error',
               'Failed to insert Lesson: ' + ERROR_MESSAGE())
    END CATCH

    
    -- try to insert student-lesson link only if both previous insertions succeeded
    IF @studentOK = 1 AND @lessonOK = 1
    BEGIN
        BEGIN TRY
            INSERT INTO StudentLessons(StudentID, LessonID, Status)
            VALUES (@newStudentID, @newLessonID, @status)

            INSERT INTO Logs(ActionName, Status, ErrorMessage)
            VALUES('sp_EnrollStudentInLesson_PartialRecovery', 'Success',
                   'Linked StudentID=' + CAST(@newStudentID AS VARCHAR) +
                   ' with LessonID=' + CAST(@newLessonID AS VARCHAR))
        END TRY
        BEGIN CATCH
            INSERT INTO Logs(ActionName, Status, ErrorMessage)
            VALUES('sp_EnrollStudentInLesson_PartialRecovery', 'Error',
                   'Failed to insert StudentLessons link: ' + ERROR_MESSAGE() +
                   ' — Student and Lesson were kept.')
        END CATCH
    END
    ELSE
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_PartialRecovery', 'Error',
               'Skipped StudentLessons link because Student OK=' + CAST(@studentOK AS VARCHAR) +
               ', Lesson OK=' + CAST(@lessonOK AS VARCHAR))
    END

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('sp_EnrollStudentInLesson_PartialRecovery', 'Completed',
           'Procedure completed. StudentOK=' + CAST(@studentOK AS VARCHAR) +
           ' LessonOK=' + CAST(@lessonOK AS VARCHAR))
END
GO


-- test cases

-- 1. successfull insertion for all 3
EXEC sp_EnrollStudentInLesson_PartialRecovery
    @studentFirstName = 'Elena',
    @studentLastName  = 'Vasile',
    @birthDate        = '2004-07-20',
    @lessonName       = 'Advanced Violin',
    @teacherLastName  = 'Neagu',
    @instrumentName   = NULL,
    @roomName         = 'Room B',
    @status           = 'Active'

SELECT * FROM Students ORDER BY StudentID DESC
SELECT * FROM Lessons ORDER BY LessonID DESC
SELECT * FROM StudentLessons ORDER BY StudentID DESC
SELECT * FROM Logs ORDER BY LogID DESC

-- 2. student fails | lesson succeeds | no link
EXEC sp_EnrollStudentInLesson_PartialRecovery
    @studentFirstName = '',
    @studentLastName  = 'Vasile',
    @birthDate        = '2004-07-20',
    @lessonName       = 'Advanced Cello',
    @teacherLastName  = 'Neagu',
    @instrumentName   = NULL,
    @roomName         = 'Room B',
    @status           = 'Active'

-- lesson 'Advanced Cello' appears in Lessons
SELECT * FROM Students ORDER BY StudentID DESC
SELECT * FROM Lessons ORDER BY LessonID DESC
SELECT * FROM Logs ORDER BY LogID DESC

-- 3. lesson fails | student succeeds | no link
EXEC sp_EnrollStudentInLesson_PartialRecovery
    @studentFirstName = 'Mihai',
    @studentLastName  = 'Constantin',
    @birthDate        = '2003-11-05',
    @lessonName       = 'Advanced Trumpet',
    @teacherLastName  = 'Nonexistent',
    @instrumentName   = NULL,
    @roomName         = 'Room B',
    @status           = 'Active'

-- student 'Mihai Constantin' appears in Students
SELECT * FROM Students ORDER BY StudentID DESC
SELECT * FROM Lessons  ORDER BY LessonID DESC
SELECT * FROM Logs ORDER BY LogID DESC

-- 4. "Harmony Basics" already exists , but student 'Radu Petrescu' is still saved
EXEC sp_EnrollStudentInLesson_PartialRecovery
    @studentFirstName = 'Radu',
    @studentLastName  = 'Petrescu',
    @birthDate        = '2005-03-18',
    @lessonName       = 'Harmony Basics', 
    @teacherLastName  = 'Neagu',
    @instrumentName   = NULL,
    @roomName         = 'Room B',
    @status           = 'Active'

SELECT * FROM Students ORDER BY StudentID DESC
SELECT * FROM Lessons  ORDER BY LessonID DESC
SELECT * FROM Logs ORDER BY LogID DESC