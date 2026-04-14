USE Music_School

-- UPDATE
UPDATE Students
SET BirthDate = '2005-02-04'
WHERE LastName LIKE '%ea' AND StudentID < 3  
 
UPDATE Lessons
SET RoomID = 2
WHERE LessonID IN (1,3)

UPDATE Grades
SET GradeValue = 8
WHERE StudentID IS NULL

-- DELETE
DELETE FROM Grades
WHERE GradeValue < 5

DELETE FROM Instruments
WHERE InstrumentID BETWEEN 6 AND 8