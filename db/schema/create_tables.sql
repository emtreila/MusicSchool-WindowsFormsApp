USE Music_School

CREATE TABLE Teachers (
	TeacherID INT PRIMARY KEY IDENTITY(1,1),
	FirstName VARCHAR(50),
	LastName VARCHAR(50),
	TeachingSubject VARCHAR(50)
);

CREATE TABLE Students(
	StudentID INT PRIMARY KEY IDENTITY(1,1),
	FirstName VARCHAR(50),
	LastName VARCHAR(50),
	BirthDate DATE
);

CREATE TABLE Instruments (
	InstrumentID INT PRIMARY KEY IDENTITY(1,1),
	InstrumentName VARCHAR(50),
);

CREATE TABLE Rooms (
	RoomID INT PRIMARY KEY IDENTITY(1,1),
	RoomName VARCHAR(100),
	Capacity INT
);

CREATE TABLE Lessons (
	LessonID INT PRIMARY KEY IDENTITY(1,1),
	LessonName VARCHAR(100),
	TeacherID INT,
	InstrumentID INT,
	RoomID INT,
	FOREIGN KEY (TeacherID) REFERENCES Teachers(TeacherID),
	FOREIGN KEY (InstrumentID) REFERENCES Instruments(InstrumentID),
	FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID)
);

CREATE TABLE InstrumentRentals (
	RentalID INT PRIMARY KEY IDENTITY(1,1),
	StartDate DATE,
	EndDate DATE,
	StudentID INT,
	InstrumentID INT,
	FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
	FOREIGN KEY (InstrumentID) REFERENCES Instruments(InstrumentID)
);

CREATE TABLE Performances (
	PerformanceID INT PRIMARY KEY IDENTITY(1,1),
	Title VARCHAR(100),
	PerformanceDate DATE
);

CREATE TABLE PerformanceParticipants (
	PerformanceID INT,
	StudentID INT,
	Role VARCHAR(50),
	PRIMARY KEY (PerformanceID, StudentID),
	FOREIGN KEY (PerformanceID) REFERENCES Performances(PerformanceID),
	FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);

CREATE TABLE Schedules (
	ScheduleID INT PRIMARY KEY IDENTITY(1,1),
	LessonID INT,
	DayOfWeek VARCHAR(50),
	StartTime TIME,
	EndTime TIME,
	FOREIGN KEY (LessonID) REFERENCES Lessons(LessonID)
);

CREATE TABLE Grades (
	GradeID INT PRIMARY KEY IDENTITY(1,1),
	StudentID INT,
	LessonID INT,
	GradeValue INT CHECK (GradeValue BETWEEN 1 AND 10),
	FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
	FOREIGN KEY (LessonID) REFERENCES Lessons(LessonID)
);

CREATE TABLE StudentLessons (
    StudentID INT,
    LessonID INT,
    Status VARCHAR(20),
    PRIMARY KEY (StudentID, LessonID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (LessonID) REFERENCES Lessons(LessonID)
);