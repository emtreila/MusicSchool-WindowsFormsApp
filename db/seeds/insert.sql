USE Music_School

SELECT * FROM Students
SELECT * FROM Teachers
SELECT * FROM Rooms
SELECT * FROM Lessons
SELECT * FROM StudentLessons
SELECT * FROM Instruments
SELECT * FROM InstrumentRentals
SELECT * FROM Grades
SELECT * FROM Performances
SELECT * FROM PerformanceParticipants
SELECT * FROM Schedules


INSERT INTO Students(FirstName,LastName,BirthDate) VALUES 
('Ana','Popescu','2003-02-19'),
('Alexandru','Bodea','2009-02-04'),
('Maria','Chric','2005-09-30'),
('Alessia','Stan','2003-10-13'),
('George','Avram','2004-12-15'),
('Andreea', 'Mihai', '2006-05-02'),
('Robert', 'Ionescu', '2008-01-28'),
('Ioana', 'Balan', '2007-03-14'),
('Stefan', 'Dumitru', '2005-11-19'),
('Carla', 'Tudor', '2004-04-22');


INSERT INTO Teachers(FirstName,LastName,TeachingSubject) VALUES 
('Maria','Brat',NULL),
('Andrei','Neagu','Music Theory'),
('Paul','Enache','Composition'),
('Cristina','Marin','Harmony'),
('Radu','Dumitrescu','Vocal Training'),
('Elena', 'Nistor', 'Orchestration'),
('Marius', 'Radu', 'Piano'),
('Laura', 'Popa', 'Flute'),
('Vlad', 'Iacob', 'Conducting');

INSERT INTO Rooms(RoomName,Capacity) VALUES 
('Room A',120),
('Room B',60),
('Room C',40),
('Room D',25),
('Room E',40);

INSERT INTO Instruments(InstrumentName) VALUES 
('Clarinet'),
('Saxophone'),
('Trombone'),
('Harp'),
('Piano'),
('Guitar'),
('Violin'),
('Trumpet'),
('Flute');

INSERT INTO Lessons(LessonName,TeacherID,InstrumentID,RoomID) VALUES 
('Introduction to Music Theory', 1, 1, 2),
('Harmony Basics', 3, NULL, 1),
('Fundamentals of Composition', 2, 2, 2),
('Vocal Techniques', 4, NULL, 3),
('Orchestration for Beginners', 5, 3, 4),
('Advanced Piano Practice', 6, 1, 5),
('Flute Ensemble', 7, 5, 2),
('Conducting Workshop', 8, NULL, 4);
-- ('Vocal Techniques', 4, NULL, 6) --> violates referential integrity constraints -> room id 6 doesnt exists

INSERT INTO Grades(StudentID, LessonID, GradeValue) VALUES
(1, 1, 9),
(2, 1, 8),
(3, 2, 10),
(4, 3, 7),
(5, 4, 10),
(6, 5, 9),
(7, 6, 10),
(8, 7, 8),
(9, 8, 9),
(10, 6, 7),
(3, 1, 8),
(4, 2, 9),
(5, 3, 10),
(6, 4, 6),
(7, 5, 10),
(8, 8, 9);
-- (5,7,12) --> violates referential integrity constraints -> the grade is between 1 and 10

INSERT INTO InstrumentRentals(StartDate, EndDate, StudentID, InstrumentID) VALUES
('2024-09-01', '2024-12-15', 1, 5),  
('2024-09-05', '2024-11-30', 2, 9),  
('2024-09-10', '2024-12-20', 3, 1),  
('2024-09-12', '2024-12-10', 4, 2),  
('2024-09-15', '2024-12-22', 5, 4),  
('2024-09-20', '2024-12-20', 6, 3),  
('2024-09-22', '2024-12-18', 7, 1),  
('2024-09-25', '2024-12-22', 8, 9),  
('2024-09-28', '2024-12-28', 9, 5), 
('2024-10-01', '2024-12-30', 10, 4); 

INSERT INTO Performances(Title, PerformanceDate) VALUES
('Autumn Harmony Concert', '2024-10-25'),
('Winter Recital', '2024-12-15'),
('Spring Gala', '2025-03-21'),
('Summer Festival', '2025-06-18');


INSERT INTO PerformanceParticipants(PerformanceID, StudentID, Role) VALUES
(1, 1, 'Pianist'),
(1, 3, 'Clarinetist'),
(1, 4, 'Vocalist'),
(2, 2, 'Flautist'),
(2, 5, 'Harpist'),
(3, 1, 'Solo Pianist'),
(3, 6, 'Trombonist'),
(3, 7, 'Clarinet Support'),
(4, 8, 'Flute Solo'),
(4, 9, 'Accompanist'),
(4, 10, 'Backup Vocal');


INSERT INTO Schedules(LessonID, DayOfWeek, StartTime, EndTime) VALUES
(1, 'Monday', '09:00', '10:30'),
(2, 'Tuesday', '10:00', '11:30'),
(3, 'Wednesday', '11:00', '12:30'),
(4, 'Thursday', '09:30', '11:00'),
(5, 'Friday', '10:00', '11:30'),
(6, 'Monday', '12:00', '13:30'),
(7, 'Tuesday', '13:00', '14:30'),
(8, 'Wednesday', '14:00', '15:30');


INSERT INTO StudentLessons(StudentID, LessonID, Status) VALUES
(1, 1, 'Active'),
(1, 6, 'Active'),
(2, 1, 'Completed'),
(2, 7, 'Active'),
(3, 2, 'Completed'),
(3, 3, 'Active'),
(4, 3, 'Active'),
(4, 4, 'Active'),
(5, 4, 'Completed'),
(5, 5, 'Active'),
(6, 5, 'Completed'),
(6, 6, 'Active'),
(7, 6, 'Completed'),
(7, 7, 'Active'),
(8, 8, 'Active'),
(9, 5, 'Dropped'),
(9, 8, 'Active'),
(10, 7, 'Active');

