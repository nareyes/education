CREATE TABLE Marks (
    Name        VARCHAR(20)
    ,Marks      INT
    ,Updated    DATETIME DEFAULT GETDATE()
);

SELECT * FROM Marks;


INSERT INTO dbo.Marks VALUES ('Ram', 75);
INSERT INTO dbo.Marks VALUES ('Shyam', 80);
INSERT INTO dbo.Marks VALUES ('Jadu', 85);
INSERT INTO dbo.Marks VALUES ('Madhu', 92);


CREATE TABLE MarksClean (
    Name        VARCHAR(20)
    ,Marks      INT
    ,Updated    DATETIME DEFAULT GETDATE()
);

SELECT * FROM MarksClean;