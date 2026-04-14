DROP VIEW IF EXISTS view1;
DROP TABLE IF EXISTS Tc;
DROP TABLE IF EXISTS Tb;
DROP TABLE IF EXISTS Ta;

DROP PROCEDURE IF EXISTS populateTableTa;
DROP PROCEDURE IF EXISTS populateTableTb;
DROP PROCEDURE IF EXISTS populateTableTc;
GO


CREATE TABLE Ta (
    aid INT NOT NULL,
    PRIMARY KEY (aid),
    a1  INT NOT NULL,
    a2  INT NOT NULL,
    UNIQUE (a2)
);
GO

CREATE TABLE Tb (
    bid INT NOT NULL,
    PRIMARY KEY (bid),
    b2  INT NOT NULL,
    b1  INT NOT NULL
);
GO

CREATE TABLE Tc (
    cid INT NOT NULL,
    PRIMARY KEY (cid),
    aid INT NOT NULL,
    FOREIGN KEY (aid) REFERENCES Ta(aid),
    bid INT NOT NULL,
    FOREIGN KEY (bid) REFERENCES Tb(bid)
);
GO


CREATE PROCEDURE populateTableTa(@rows INT) AS
WHILE @rows > 0
BEGIN
    INSERT INTO Ta
    VALUES (
        @rows,
        (@rows % 1000) * 10,
        @rows
    );

    SET @rows = @rows - 1;
END;
GO

CREATE PROCEDURE populateTableTb(@rows INT) AS
WHILE @rows > 0
BEGIN
    INSERT INTO Tb
    VALUES (
        @rows,
        @rows % 1000,
        @rows * 2
    );

    SET @rows = @rows - 1;
END;
GO


CREATE PROCEDURE populateTableTc(@rows INT) AS
BEGIN
    IF @rows > (SELECT COUNT(*) FROM Ta) * (SELECT COUNT(*) FROM Tb) -- check if @rows > (aid, bid) pairs
    BEGIN
        RAISERROR ('Too many entities requested', 10, 1);
        RETURN;
    END;

    INSERT INTO Tc (cid, aid, bid)
    SELECT TOP (@rows)
           ROW_NUMBER() OVER (ORDER BY a.aid, b.bid) AS cid,
           a.aid,
           b.bid
    FROM Ta a
    CROSS JOIN Tb b; -- create all possible combinations (aid,bid pairs)
END;
GO


EXEC populateTableTa 10000;
EXEC populateTableTb 10000;
EXEC populateTableTc 12000;
GO


-- 1) Clustered Index Scan 
SELECT *
FROM Ta
WHERE aid > 0;
GO

-- 2) Clustered Index Seek
SELECT *
FROM Ta
WHERE aid = 100;
GO


-- 3) Nonclustered Index Seek 
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Ta_a2')
    DROP INDEX IX_Ta_a2 ON Ta;
GO

CREATE NONCLUSTERED INDEX IX_Ta_a2 ON Ta(a2);
GO

SELECT *
FROM Ta
WHERE a2 = 14;
GO

-- 4) Nonclustered Index Scan 
SELECT *
FROM Ta
WHERE a2 <= 8000;
GO

-- 5) Key Lookup
SELECT *
FROM Ta
WHERE a2 = 30;



IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Tb_b2')
    DROP INDEX IX_Tb_b2 ON Tb;
GO

-- make a scan because there are no indexes on b2
SELECT *
FROM Tb
WHERE b2 = 0;
GO

-- after creating an index -> seek
CREATE NONCLUSTERED INDEX IX_Tb_b2 ON Tb(b2);
GO

SELECT *
FROM Tb
WHERE b2 = 0;
GO



-- joins tables Tc, Ta, Tb and groups the results by bid, and computes the sum of a2 values for each group
CREATE OR ALTER VIEW view1 AS
    SELECT c.bid, SUM(a.a2) AS suma2
    FROM Tc c
        INNER JOIN Tb b ON c.bid = b.bid
        INNER JOIN Ta a ON c.aid = a.aid
    WHERE a.a2 <= 10000
      AND b.b2 <= 10000
    GROUP BY c.bid;
GO

--SELECT COUNT(*) AS Ta_rows FROM Ta;
--SELECT COUNT(*) AS Tb_rows FROM Tb;
--SELECT COUNT(*) AS Tc_rows FROM Tc;
--GO


--SELECT COUNT(*) AS Ta_filtered
--FROM Ta
--WHERE a2 <= 10000;

--SELECT COUNT(*) AS Tb_filtered
--FROM Tb
--WHERE b2 <= 10000;
--GO


IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Ta_a2')
    DROP INDEX IX_Ta_a2 ON Ta;

IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Tb_b2')
    DROP INDEX IX_Tb_b2 ON Tb;
GO


SELECT * FROM view1;
GO

CREATE NONCLUSTERED INDEX IX_Ta_a2 ON Ta(a2);
CREATE NONCLUSTERED INDEX IX_Tb_b2 ON Tb(b2);
GO

SELECT * FROM view1;
GO

