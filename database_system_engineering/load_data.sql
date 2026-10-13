-- Temp Tables
CREATE TABLE TempHasSkills(
    Nickname VARCHAR(100) NOT NULL,
    SkillDescription VARCHAR(100) NOT NULL,
    Preference INT,
    Grade VARCHAR(5)
);

CREATE TABLE TempHasAccounts(
    Nickname VARCHAR(100) NOT NULL,
    BankName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL
);

CREATE TABLE TempAccomplices(
    Nickname VARCHAR(100) NOT NULL,
    BankName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Date DATE NOT NULL,
    Share DECIMAL(10, 2) CHECK (Share >= 0)
);


-- Populate Temp tables (No FK constraints required, as they're in main tables)
\copy TempHasSkills(Nickname, SkillDescription, Preference, Grade) FROM 'data/hasskills_25.data' WITH (FORMAT text)
\copy TempHasAccounts(Nickname, BankName, City) FROM 'data/hasaccounts_25.data' WITH (FORMAT text)
\copy TempAccomplices(Nickname, BankName, City, Date, Share) FROM 'data/accomplices_25.data' WITH (FORMAT text)


-- Populating Banks and Robbers
\copy Banks(BankName, City, NoAccounts, Security) FROM 'data/banks_25.data' WITH (FORMAT text)
\copy Robbers(Nickname, Age, NoYears) FROM 'data/robbers_25.data' WITH (FORMAT text)


-- Populating the Skills table
INSERT INTO Skills(Description) SELECT DISTINCT SkillDescription FROM TempHasSkills;


-- Populating the Robberies and Plans table
\copy Robberies(BankName, City, Date, Amount) FROM 'data/robberies_25.data' WITH (FORMAT text)
\copy Plans(BankName, City, PlannedDate, NoRobbers) FROM 'data/plans_25.data' WITH (FORMAT text)


-- Populating the HasSkills table
INSERT INTO HasSkills(RobberID, SkillID, Preference, Grade)
SELECT r.RobberID, s.SkillID, t.Preference, TRIM(t.Grade)
FROM TempHasSkills t
JOIN Robbers r ON t.Nickname = r.Nickname
JOIN Skills s ON t.SkillDescription = s.Description;

-- Populating the HasAccounts table
INSERT INTO HasAccounts(RobberID, BankName, City)
SELECT r.RobberID, t.BankName, t.City
FROM TempHasAccounts t
JOIN Robbers r ON t.Nickname = r.Nickname;

-- Populating the Accomplices table
INSERT INTO Accomplices(RobberID, BankName, City, Date, Share)
SELECT r.RobberID, t.BankName, t.City, t.Date, t.Share
FROM TempAccomplices t
JOIN Robbers r ON t.Nickname = r.Nickname;


-- Delete TEMP tables
DROP TABLE TempHasSkills;
DROP TABLE TempHasAccounts;
DROP TABLE TempAccomplices;