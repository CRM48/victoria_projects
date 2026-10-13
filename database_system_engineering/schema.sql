-- Create tables
CREATE TABLE Banks(
    BankName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,
    NoAccounts INT CHECK (NoAccounts >= 0),
    Security VARCHAR(100) DEFAULT 'unknown' CHECK (Security IN ('weak', 'good', 'very good', 'excellent', 'unknown')),
    PRIMARY KEY (City, BankName)
);

CREATE TABLE Robbers(
    RobberID SERIAL PRIMARY KEY,
    Nickname VARCHAR(100) NOT NULL,
    Age INT CHECK (Age >= 0 AND Age <= 130),
    NoYears INT CHECK (NoYears >= 0),
    CONSTRAINT chk_NoYears CHECK (NoYears <= Age)
);

CREATE TABLE Skills(
    SkillID SERIAL PRIMARY KEY,
    Description VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Robberies(
    BankName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Date DATE NOT NULL,
    Amount DECIMAL(10, 2) CHECK (Amount >= 0),
    PRIMARY KEY(BankName, City, Date),
    FOREIGN KEY(BankName, City) REFERENCES Banks(BankName, City) ON UPDATE CASCADE
);

CREATE TABLE Plans(
    BankName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,
    PlannedDate DATE NOT NULL,
    NoRobbers INT CHECK (NoRobbers >= 1),
    PRIMARY KEY(BankName, City, PlannedDate),
    FOREIGN KEY(BankName, City) REFERENCES Banks(BankName, City) ON UPDATE CASCADE
);

CREATE TABLE HasSkills(
    RobberID INT NOT NULL,
    SkillID INT NOT NULL,
    Preference INT CHECK (Preference >= 1),
    Grade VARCHAR(5) CHECK (Grade IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'F')),
    PRIMARY KEY(RobberID, SkillID),
    FOREIGN KEY(RobberID) REFERENCES Robbers(RobberID) ON DELETE CASCADE,
    FOREIGN KEY(SkillID) REFERENCES Skills(SkillID) ON DELETE CASCADE,
    CONSTRAINT unique_robber_preference UNIQUE (RobberID, Preference)
);

CREATE TABLE HasAccounts(
    RobberID INT NOT NULL,
    BankName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,
    PRIMARY KEY(RobberID, BankName, City),
    FOREIGN KEY(RobberID) REFERENCES Robbers(RobberID) ON DELETE CASCADE,
    FOREIGN KEY(BankName, City) REFERENCES Banks(BankName, City) ON UPDATE CASCADE
);

CREATE TABLE Accomplices(
    RobberID INT NOT NULL,
    BankName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Date DATE NOT NULL,
    Share DECIMAL(10, 2) CHECK (Share >= 0),
    PRIMARY KEY(RobberID, BankName, City, Date),
    FOREIGN KEY(RobberID) REFERENCES Robbers(RobberID) ON DELETE CASCADE,
    FOREIGN KEY(BankName, City, Date) REFERENCES Robberies(BankName, City, Date) ON DELETE CASCADE ON UPDATE CASCADE
);