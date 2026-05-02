USE MusicSchool
GO

IF OBJECT_ID('Logs', 'U') IS NOT NULL DROP TABLE Logs
GO

CREATE TABLE Logs (
    LogID        INT PRIMARY KEY IDENTITY(1,1),
    ActionName   VARCHAR(100),
    Status       VARCHAR(50),
    ErrorMessage VARCHAR(500),
    LogTimestamp DATETIME DEFAULT GETDATE()
)
GO