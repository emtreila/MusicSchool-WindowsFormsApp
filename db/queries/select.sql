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


--		a) 2 queries with the union operation; use UNION [ALL] and OR
-- 1) Display the ids of students whose names start with the letter A or have grades < 9

SELECT S.StudentID
FROM Students S
WHERE S.FirstName LIKE 'A%'
UNION ALL
SELECT G.StudentID
FROM Grades G
WHERE G.GradeValue < 9

-- 2) Display the ids of teachers who either do not use any instruments when teaching 
--     or have a first name ending with 'na', but exclude teachers whose names start with 'R'.

SELECT L.TeacherID
FROM Lessons L
WHERE (L.InstrumentID IS NULL OR L.InstrumentID = 0) AND NOT (L.TeacherID IN (
		SELECT T.TeacherID
		FROM Teachers T
		WHERE T.FirstName LIKE 'R%'
	))


--		b) 2 queries with the intersection operation; use INTERSECT and IN
-- 3) Display the ids of students who are younger than 21 years old (born between 2004 and 2009)
--     or whose first name starts with 'A', and who have at least one grade greater than 8.

SELECT S.StudentID
FROM Students S
WHERE (S.BirthDate > '2004-01-01' AND S.BirthDate < '2009-01-01')
   OR S.FirstName LIKE 'A%'
INTERSECT
SELECT G.StudentID
FROM Grades G
WHERE G.GradeValue >  8


-- 4) Display the ids of performance participants who rented an instrument

SELECT Perf.PerformanceID
FROM PerformanceParticipants Perf
WHERE Perf.PerformanceID IN (
	SELECT I.StudentID
	FROM InstrumentRentals I
);


--		c) 2 queries with the difference operation; use EXCEPT and NOT IN
-- 5) Lessons that exist but do not appear in Grades

SELECT L.LessonID
FROM Lessons L
EXCEPT
SELECT G.LessonID
FROM Grades G;


-- 6) Display the ids of students who received grades but didnt participate in any performances

SELECT G.StudentID
FROM Grades G
WHERE G.StudentID NOT IN (
	SELECT P.StudentID
	FROM PerformanceParticipants P
);


-- d. 4 queries with INNER JOIN, LEFT JOIN, RIGHT JOIN, and FULL JOIN (one 
-- query per operator); one query will join at least 3 tables, while another 
-- one will join at least two many-to-many relationships; 
-- 7) Display the full name of students, their grade value, the next possible grade (+1), 
--     and the lesson title they got their grade on. 
--     Results are ordered by grade value in descending order. 

SELECT S.FirstName, S.LastName, G.GradeValue, G.GradeValue + 1 AS NextGrade, L.LessonName
FROM Students S INNER JOIN Grades G ON S.StudentID = G.StudentID 
				INNER JOIN Lessons L ON G.LessonID = L.LessonID
ORDER BY G.GradeValue DESC;               


-- 8) Display the full name of teachers together with the titles of the lessons they teach,
-- including those teachers who currently do not have any lessons assigned.

SELECT T.FirstName, T.LastName, L.LessonName
FROM Teachers T
LEFT JOIN Lessons L ON T.TeacherID = L.TeacherID

-- 9) Display the names of all instruments together with the IDs of the students who rented them,
--    including instruments that have never been rented by anyone

SELECT I.InstrumentName, IR.StudentID
FROM InstrumentRentals IR
RIGHT JOIN Instruments I ON I.InstrumentID = IR.InstrumentID

-- 10) Display all students who either participated in a performance or are enrolled in a lesson (or both) -> many to many

SELECT 
    COALESCE(PP.StudentID, SL.StudentID) AS StudentID, S.FirstName, S.LastName
FROM PerformanceParticipants PP
FULL JOIN StudentLessons SL ON PP.StudentID = SL.StudentID
JOIN Students S ON S.StudentID = COALESCE(PP.StudentID, SL.StudentID);


-- e. 2 queries using the IN operator to introduce a subquery in the WHERE 
-- clause; in at least one query, the subquery should include a subquery in 
-- its own WHERE clause; 
-- 11) Display the full names of students who received grades for lessons taught by teachers
--     with the teaching subject 'Piano', excluding teachers whose names start with 'R' or end with 'escu'.

SELECT S.FirstName, S.LastName
FROM Students S
WHERE S.StudentID IN (
	SELECT G.StudentID
	FROM Grades G
	WHERE G.LessonID IN (
		SELECT L.LessonID
		FROM Lessons L
		WHERE L.TeacherID IN (
			SELECT T.TeacherID
			FROM Teachers T
			WHERE T.TeachingSubject = 'Piano'
			  AND NOT (T.FirstName LIKE 'R%' OR T.LastName LIKE '%escu')
		)
	)
);


-- 12) Display the full names of students who have participated in performances

SELECT S.FirstName, S.LastName
FROM Students S
WHERE S.StudentID IN (
	SELECT PP.StudentID
	FROM PerformanceParticipants PP
);


-- f) 2 queries using the EXISTS operator to introduce a subquery in the WHERE clause.
-- 13) Display the full names of students and the ids for whom there exists at least one grade
--     with a value greater than 8 

SELECT S.FirstName, S.LastName, S.StudentID
FROM Students S
WHERE EXISTS (
	SELECT G.StudentID
	FROM Grades G
	WHERE G.StudentID = S.StudentID AND G.GradeValue > 8
);

-- 14) Show the full names of teachers for whom there exists at least one lesson
--     that takes place in a room with a capacity greater than 50

SELECT T.FirstName, T.LastName
FROM Teachers T
WHERE EXISTS (
	SELECT L.LessonID
	FROM Lessons L
	WHERE T.TeacherID = L.TeacherID AND EXISTS (
		SELECT R.RoomID
		FROM Rooms R
		WHERE L.RoomID = R.RoomID AND R.Capacity > 50
	)
);


-- g. 2 queries with a subquery in the FROM clause; 
-- 15) Show each room and how many lessons are scheduled there, using a subquery in FROM

SELECT R.RoomName, X.NumLessons
FROM Rooms R
JOIN (
    SELECT RoomID, COUNT(*) AS NumLessons
    FROM Lessons
    GROUP BY RoomID
) AS X
ON R.RoomID = X.RoomID;


-- 16) Show each student and how many instruments they rented, using a subquery in FROM

SELECT S.FirstName, S.LastName, IRcnt.RentalCount
FROM Students S
JOIN (
    SELECT IR.StudentID, COUNT(*) AS RentalCount
    FROM InstrumentRentals IR
    GROUP BY IR.StudentID
) AS IRcnt
ON S.StudentID = IRcnt.StudentID;



-- h. 4 queries with the GROUP BY clause, 3 of which also contain the 
-- HAVING clause; 2 of the latter will also have a subquery in the HAVING 
-- clause; use the aggregation operators: COUNT, SUM, AVG, MIN, MAX; 
-- 17) Display the top 5 rooms with the number of lessons that take place in each,
--     showing also double that number (COUNT * 2). Results are ordered by number of lessons descending.

SELECT TOP 5                                   
       R.RoomName, 
       COUNT(L.LessonID) AS NumberOfLessons,
       COUNT(L.LessonID) * 2 AS DoubleLessons  
FROM Rooms R INNER JOIN Lessons L ON R.RoomID = L.RoomID
GROUP BY R.RoomName
ORDER BY NumberOfLessons DESC;                


-- 18) Show the top 10 students with the total number of instruments they rented
--     and a calculated score (COUNT * 10) as 'RentalPoints'. 
--     Display only those who rented more than one instrument, ordered by RentalPoints descending.

SELECT TOP 10
       S.StudentID, S.FirstName, S.LastName,
       COUNT(I.InstrumentID) AS NumberOfInstrumentsRented,
       COUNT(I.InstrumentID) * 10 AS RentalPoints  
FROM Students S INNER JOIN InstrumentRentals I ON S.StudentID = I.StudentID
GROUP BY S.StudentID, S.FirstName, S.LastName
HAVING COUNT(I.InstrumentID) > 1
ORDER BY RentalPoints DESC;                        

-- 19) Display the students whose average grade is higher than the overall average grade (HAVING, AVG)

SELECT S.StudentID, S.FirstName, S.LastName, 
	AVG(G.GradeValue) AS AverageGrade
FROM Students S INNER JOIN Grades G ON S.StudentID = G.StudentID
GROUP BY S.StudentID, S.FirstName, S.LastName
HAVING AVG(G.GradeValue) > (
    SELECT AVG(GradeValue)
    FROM Grades
);

-- 20) Show the rooms where the maximum room capacity is greater than the minimum capacity
--     among all rooms (HAVING, MIN, MAX)

SELECT R.RoomName, MAX(R.Capacity) AS MaxCapacity
FROM Rooms R
GROUP BY R.RoomName
HAVING MAX(R.Capacity) > (
    SELECT MIN(R2.Capacity)
    FROM Rooms R2
);

-- i. 4 queries using ANY and ALL to introduce a subquery in the WHERE 
-- clause; rewrite 2 of them with aggregation operators, and the other 2 
-- with [NOT] IN. 
-- 21) Find all student ids who have a grade strictly higher than ANY grade of Ana (StudentID = 1)

SELECT DISTINCT G.StudentID
FROM Grades G
WHERE G.GradeValue > ANY (
	SELECT G2.GradeValue
	FROM Grades G2
	WHERE StudentID = 1
);

SELECT DISTINCT G.StudentID
FROM Grades G
WHERE G.GradeValue > (
    SELECT MIN(GradeValue)
    FROM Grades
    WHERE StudentID = 1
);

-- 22) Find the ids of students who have a grade that is >= all of Anas grades

SELECT DISTINCT G.StudentID
FROM Grades G
WHERE G.GradeValue >= ALL (
    SELECT GradeValue
    FROM Grades
    WHERE StudentID = 1
);

SELECT DISTINCT G.StudentID
FROM Grades G
WHERE G.GradeValue >= (
    SELECT MAX(GradeValue)
    FROM Grades
    WHERE StudentID = 1
);
-- 23) Show the full names of students who have at least one grade equal to any grade from lesson 1

SELECT DISTINCT S.FirstName,S.LastName
FROM Students S INNER JOIN Grades G ON S.StudentID = G.StudentID
WHERE G.GradeValue = ANY (
    SELECT GradeValue
    FROM Grades
    WHERE LessonID = 1
);

SELECT DISTINCT S.FirstName,S.LastName 
FROM Students S INNER JOIN Grades G ON S.StudentID = G.StudentID
WHERE G.GradeValue IN (
    SELECT GradeValue
    FROM Grades
    WHERE LessonID = 1
);
-- 24) Show the full names of students whose grades are higher than all grades obtained by Ana

SELECT DISTINCT S.FirstName,S.LastName 
FROM Students S INNER JOIN Grades G ON S.StudentID = G.StudentID
WHERE G.GradeValue > ALL (
    SELECT GradeValue
    FROM Grades
    WHERE StudentID = 1
);

SELECT DISTINCT S.FirstName,S.LastName 
FROM Students S INNER JOIN Grades G ON S.StudentID = G.StudentID
WHERE G.GradeValue NOT IN (
    SELECT GradeValue
    FROM Grades
    WHERE GradeValue <= (
        SELECT MAX(GradeValue)
        FROM Grades
        WHERE StudentID = 1
	)
);