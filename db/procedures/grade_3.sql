USE MusicSchool
GO


IF OBJECT_ID('fn_IsEmptyString', 'FN') IS NOT NULL DROP FUNCTION fn_IsEmptyString
GO

CREATE FUNCTION fn_IsEmptyString (@string VARCHAR(500))
RETURNS INT
AS
BEGIN
    IF @string IS NULL OR LTRIM(RTRIM(@string)) = ''
        RETURN 0
    RETURN 1
END
GO

IF OBJECT_ID('fn_IsValidBirthDate', 'FN') IS NOT NULL DROP FUNCTION fn_IsValidBirthDate
GO

CREATE FUNCTION fn_IsValidBirthDate (@birthDate DATE)
RETURNS INT
AS
BEGIN
    IF @birthDate IS NULL OR @birthDate >= CAST(GETDATE() AS DATE)
        RETURN 0
    RETURN 1
END
GO

IF OBJECT_ID('sp_AddStudent', 'P') IS NOT NULL DROP PROCEDURE sp_AddStudent
GO

CREATE PROCEDURE sp_AddStudent
    @studentFirstName VARCHAR(50),
    @studentLastName  VARCHAR(50),
    @birthDate        DATE,
    @newStudentID     INT OUTPUT   -- returns the new ID to the caller
AS
BEGIN
    SET NOCOUNT ON;

    -- validation
    IF dbo.fn_IsEmptyString(@studentFirstName) = 0
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_AddStudent', 'Error', 'Student first name cannot be empty.')
        RAISERROR('Student first name cannot be empty.', 16, 1)
        RETURN
    END

    IF dbo.fn_IsEmptyString(@studentLastName) = 0
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_AddStudent', 'Error', 'Student last name cannot be empty.')
        RAISERROR('Student last name cannot be empty.', 16, 1)
        RETURN
    END

    IF dbo.fn_IsValidBirthDate(@birthDate) = 0
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_AddStudent', 'Error', 'Birth date is invalid or in the future.')
        RAISERROR('Birth date is invalid or in the future.', 16, 1)
        RETURN
    END

    -- insert
    INSERT INTO Students(FirstName, LastName, BirthDate)
    VALUES (@studentFirstName, @studentLastName, @birthDate)

    SET @newStudentID = SCOPE_IDENTITY()

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('sp_AddStudent', 'Success',
           'Inserted Student: ' + @studentFirstName + ' ' + @studentLastName +
           ' with ID=' + CAST(@newStudentID AS VARCHAR))
END
GO


IF OBJECT_ID('sp_AddLesson', 'P') IS NOT NULL DROP PROCEDURE sp_AddLesson
GO

CREATE PROCEDURE sp_AddLesson
    @lessonName      VARCHAR(100),
    @teacherLastName VARCHAR(50),
    @instrumentName  VARCHAR(50),   -- nullable
    @roomName        VARCHAR(100),
    @newLessonID     INT OUTPUT     -- returns the new ID to the caller
AS
BEGIN
    SET NOCOUNT ON;

    -- validation
    IF dbo.fn_IsEmptyString(@lessonName) = 0
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_AddLesson', 'Error', 'Lesson name cannot be empty.')
        RAISERROR('Lesson name cannot be empty.', 16, 1)
        RETURN
    END

    IF dbo.fn_IsEmptyString(@teacherLastName) = 0
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_AddLesson', 'Error', 'Teacher last name cannot be empty.')
        RAISERROR('Teacher last name cannot be empty.', 16, 1)
        RETURN
    END

    IF dbo.fn_IsEmptyString(@roomName) = 0
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_AddLesson', 'Error', 'Room name cannot be empty.')
        RAISERROR('Room name cannot be empty.', 16, 1)
        RETURN
    END

    -- check if foreign keys exist
    DECLARE @teacherID    INT
    DECLARE @instrumentID INT
    DECLARE @roomID       INT

    SELECT @teacherID = TeacherID
    FROM Teachers
    WHERE LastName = @teacherLastName

    IF @teacherID IS NULL
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_AddLesson', 'Error', 'Teacher not found: ' + @teacherLastName)
        RAISERROR('Teacher not found.', 16, 1)
        RETURN
    END

    IF dbo.fn_IsEmptyString(@instrumentName) = 1
    BEGIN
        SELECT @instrumentID = InstrumentID
        FROM Instruments
        WHERE InstrumentName = @instrumentName

        IF @instrumentID IS NULL
        BEGIN
            INSERT INTO Logs(ActionName, Status, ErrorMessage)
            VALUES('sp_AddLesson', 'Error', 'Instrument not found: ' + @instrumentName)
            RAISERROR('Instrument not found.', 16, 1)
            RETURN
        END
    END

    SELECT @roomID = RoomID
    FROM Rooms
    WHERE RoomName = @roomName

    IF @roomID IS NULL
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_AddLesson', 'Error', 'Room not found: ' + @roomName)
        RAISERROR('Room not found.', 16, 1)
        RETURN
    END

    -- insert
    INSERT INTO Lessons(LessonName, TeacherID, InstrumentID, RoomID)
    VALUES (@lessonName, @teacherID, @instrumentID, @roomID)

    SET @newLessonID = SCOPE_IDENTITY()

    INSERT INTO Logs(ActionName, Status, ErrorMessage)
    VALUES('sp_AddLesson', 'Success',
           'Inserted Lesson: ' + @lessonName +
           ' with ID=' + CAST(@newLessonID AS VARCHAR))
END
GO

IF OBJECT_ID('sp_EnrollStudentInLesson_FullRollback', 'P') IS NOT NULL DROP PROCEDURE sp_EnrollStudentInLesson_FullRollback
GO

CREATE PROCEDURE sp_EnrollStudentInLesson_FullRollback
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

    -- validation for status
    IF @status NOT IN ('Active', 'Completed', 'Dropped')
    BEGIN
        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_FullRollback', 'Error', 
               'Status must be Active, Completed, or Dropped.')
        RAISERROR('Status must be Active, Completed, or Dropped.', 16, 1)
        RETURN
    END

    DECLARE @newStudentID INT
    DECLARE @newLessonID  INT

    BEGIN TRY
        BEGIN TRANSACTION

        EXEC sp_AddStudent
            @studentFirstName = @studentFirstName,
            @studentLastName  = @studentLastName,
            @birthDate        = @birthDate,
            @newStudentID     = @newStudentID OUTPUT

        EXEC sp_AddLesson
            @lessonName      = @lessonName,
            @teacherLastName = @teacherLastName,
            @instrumentName  = @instrumentName,
            @roomName        = @roomName,
            @newLessonID     = @newLessonID OUTPUT

        INSERT INTO StudentLessons(StudentID, LessonID, Status)
        VALUES (@newStudentID, @newLessonID, @status)

        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_FullRollback', 'Success',
               'Linked StudentID=' + CAST(@newStudentID AS VARCHAR) +
               ' with LessonID=' + CAST(@newLessonID AS VARCHAR))

        COMMIT TRANSACTION

        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_FullRollback', 'Success',
               'Transaction committed successfully.')

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION

        INSERT INTO Logs(ActionName, Status, ErrorMessage)
        VALUES('sp_EnrollStudentInLesson_FullRollback', 'Rollback',
               'Transaction rolled back. Reason: ' + ERROR_MESSAGE())

        RAISERROR('Transaction failed and was fully rolled back. See Logs for details.', 16, 1)
    END CATCH
END
GO

-- test cases

-- 1. successful procedure
EXEC sp_EnrollStudentInLesson_FullRollback
    @studentFirstName = 'Diana',
    @studentLastName  = 'Florescu',
    @birthDate        = '2005-06-15',
    @lessonName       = 'Jazz Fundamentals',
    @teacherLastName  = 'Neagu',
    @instrumentName   = NULL,
    @roomName         = 'Room C',
    @status           = 'Active'

SELECT * FROM Students ORDER BY StudentID DESC
SELECT * FROM Lessons ORDER BY LessonID DESC
SELECT * FROM StudentLessons ORDER BY StudentID DESC
SELECT * FROM Logs ORDER BY LogID DESC

-- 2. empty first name
EXEC sp_EnrollStudentInLesson_FullRollback
    @studentFirstName = '',
    @studentLastName  = 'Florescu',
    @birthDate        = '2005-06-15',
    @lessonName       = 'Jazz Fundamentals',
    @teacherLastName  = 'Neagu',
    @instrumentName   = NULL,
    @roomName         = 'Room C',
    @status           = 'Active'

SELECT * FROM Students ORDER BY StudentID DESC
SELECT * FROM Logs ORDER BY LogID DESC

-- 3. future birth date
EXEC sp_EnrollStudentInLesson_FullRollback
    @studentFirstName = 'Diana',
    @studentLastName  = 'Florescu',
    @birthDate        = '2035-01-01',
    @lessonName       = 'Jazz Fundamentals',
    @teacherLastName  = 'Neagu',
    @instrumentName   = NULL,
    @roomName         = 'Room C',
    @status           = 'Active'

SELECT * FROM Students ORDER BY StudentID DESC
SELECT * FROM Logs ORDER BY LogID DESC

-- 4. teacher not found
EXEC sp_EnrollStudentInLesson_FullRollback
    @studentFirstName = 'Diana',
    @studentLastName  = 'Florescu',
    @birthDate        = '2005-06-15',
    @lessonName       = 'Jazz Fundamentals',
    @teacherLastName  = 'Nonexistent',
    @instrumentName   = NULL,
    @roomName         = 'Room C',
    @status           = 'Active'

SELECT * FROM Lessons ORDER BY LessonID DESC
SELECT * FROM Logs ORDER BY LogID DESC

-- 5. invalid status
EXEC sp_EnrollStudentInLesson_FullRollback
    @studentFirstName = 'Diana',
    @studentLastName  = 'Florescu',
    @birthDate        = '2005-06-15',
    @lessonName       = 'Jazz Fundamentals',
    @teacherLastName  = 'Neagu',
    @instrumentName   = NULL,
    @roomName         = 'Room C',
    @status           = 'Pending'

SELECT * FROM Students ORDER BY StudentID DESC
SELECT * FROM Lessons ORDER BY LessonID DESC
SELECT * FROM StudentLessons ORDER BY StudentID DESC
SELECT * FROM Logs ORDER BY LogID DESC

-- 6. 'Jazz Fundamentals' already exists -> Bogdan should NOT appear in Students after this
EXEC sp_EnrollStudentInLesson_FullRollback
    @studentFirstName = 'Bogdan',
    @studentLastName  = 'Ionescu',
    @birthDate        = '2006-03-10',
    @lessonName       = 'Jazz Fundamentals',
    @teacherLastName  = 'Neagu',
    @instrumentName   = NULL,
    @roomName         = 'Room C',
    @status           = 'Active'

SELECT * FROM Students ORDER BY StudentID DESC
SELECT * FROM Logs     ORDER BY LogID     DESC