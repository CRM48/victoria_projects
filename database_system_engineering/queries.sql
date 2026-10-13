
-- Banks that have never been robbed
SELECT b.BankName, b.City
FROM Banks b
LEFT JOIN Robberies r ON b.BankName = r.BankName AND b.City = r.City
WHERE r.BankName IS NULL;

-- Robbers who have spent more than half their lives in prison
SELECT RobberID, NickName, (Age - NoYears) AS YearsNotInPrison
FROM Robbers
WHERE (NoYears > Age/2);

-- Skills held by robbers aged 35 or older
SELECT r.RobberID, r.NickName, r.Age, s.Description
FROM Robbers r
JOIN HasSkills h ON r.RobberID = h.RobberID
JOIN Skills s ON h.SkillID = s.SkillID
WHERE r.Age >= 35;

-- Banks where Al Capone holds an account
SELECT a.BankName, a.City
FROM HasAccounts a
JOIN Robbers r ON a.RobberID = r.RobberID
WHERE r.Nickname = 'Al Capone';

-- Robbers with total earnings of at least 50,000
SELECT a.RobberID, r.NickName, SUM(a.Share) AS TotalEarnings
FROM Accomplices a
JOIN Robbers r ON a.RobberID = r.RobberID
GROUP BY a.RobberID, r.NickName
HAVING SUM(a.Share) >= 50000
ORDER BY TotalEarnings DESC;

-- Skills and the robbers who possess them
SELECT s.Description, r.RobberID, r.NickName
FROM Skills s
JOIN HasSkills h ON s.SkillID = h.SkillID
JOIN Robbers r ON h.RobberID = r.RobberID
ORDER BY s.Description;


-- Total earnings of robbers involved in the largest robbery

-- Approach 1: Use views to find the largest robbery, identify its
-- participants, and then calculate their total earnings.

-- Find the largest robbery amount
CREATE OR REPLACE VIEW LargestRobberyAmount AS
SELECT Max(Amount) AS MaxAmt
FROM Robberies;

-- Find the robbery associated with that amount
CREATE OR REPLACE VIEW LargestRobbery AS
SELECT BankName, City, Date
FROM Robberies
WHERE Amount = (SELECT MaxAmt FROM LargestRobberyAmount);

-- Find the robbers involved in that robbery
CREATE OR REPLACE VIEW RobberyAccomplices AS
SELECT a.RobberID
FROM Accomplices A
JOIN LargestRobbery l ON a.BankName = l.BankName AND a.City = l.City AND a.Date = l.Date;

-- Calculate the total earnings of those robbers
SELECT a.RobberID, r.NickName, SUM(a.Share) AS TotalEarnings
FROM Accomplices a
JOIN Robbers r ON a.RobberID = r.RobberID
JOIN RobberyAccomplices ra ON r.RobberID = ra.RobberID
GROUP BY a.RobberID, r.NickName
ORDER BY TotalEarnings DESC;

-- Approach 2: Use nested subqueries to identify participants
-- in the largest robbery without creating views.
SELECT a.RobberID, r.Nickname, SUM(a.SHARE) AS TotalEarnings
FROM Accomplices a
JOIN Robbers r ON a.RobberID = r.RobberID
WHERE r.RobberID IN (
    SELECT a2.RobberID
    FROM Accomplices a2
    JOIN Robberies ra ON a2.BankName = ra.BankName AND a2.City = ra.City AND a2.Date = ra.Date
    WHERE ra.Amount = (
        SELECT MAX(Amount)
        FROM Robberies
    )
)
GROUP BY a.RobberID, r.NickName
ORDER BY TotalEarnings DESC;


-- Preferred skills of robbers who have more than one skill

-- Approach 1: Use views to identify multi-skilled robbers
-- and retrieve their preferred skills.
CREATE OR REPLACE VIEW TwoPlusSkilledRobbers AS
SELECT RobberID
FROM HasSkills
GROUP BY RobberID
HAVING COUNT(*) > 1;

CREATE OR REPLACE VIEW PreferredSkill AS
SELECT h.RobberID, s.Description
FROM HasSkills h
JOIN Skills s ON h.SkillID = s.SkillID
WHERE h.Preference = 1
AND h.RobberID IN (SELECT RobberID FROM TwoPlusSkilledRobbers);

SELECT r.RobberID, r.NickName, p.Description AS PreferredSkill
FROM Robbers r
JOIN PreferredSkill p ON r.RobberID = p.RobberID;

-- Approach 2: Use a subquery to filter multi-skilled robbers
-- and retrieve their preferred skills in a single statement.
SELECT r.RobberID, r.NickName, s.Description AS PreferredSkill
FROM Robbers r
JOIN HasSkills h ON r.RobberID = h.RobberID
JOIN Skills s ON h.SkillID = s.SkillID
WHERE h.Preference = 1
AND r.RobberID IN (
    SELECT RobberID
    FROM HasSkills
    GROUP BY RobberID
    HAVING COUNT(*) > 1
);


-- Banks with planned robberies in years when they were not robbed

-- Approach 1: Create views of planned and completed robbery years,
-- then use a LEFT JOIN to find planned years with no completed robbery.
CREATE OR REPLACE VIEW PlannedRobberyYears AS
SELECT DISTINCT BankName, City, EXTRACT (YEAR FROM PlannedDate) AS Year
FROM Plans;

CREATE OR REPLACE VIEW PastRobberyYears AS
SELECT DISTINCT BankName, City, EXTRACT (YEAR FROM Date) AS Year
FROM Robberies;

SELECT p.BankName, p.City, p.Year
FROM PlannedRobberyYears p
LEFT JOIN PastRobberyYears r ON p.BankName = r.BankName AND p.City = r.City AND p.Year = r.Year
WHERE r.BankName IS NULL;

-- Approach 2: Use subqueries instead of views to compare
-- planned and completed robbery years.
SELECT p.BankName, p.City, p.Year
FROM (
    SELECT DISTINCT BankName, City, EXTRACT (YEAR FROM PlannedDate) AS Year
    FROM Plans
) p
LEFT JOIN (
    SELECT DISTINCT BankName, City, EXTRACT (YEAR FROM Date) AS Year
    FROM Robberies
) r
ON p.BankName = r.BankName AND p.City = r.City AND p.Year = r.Year
WHERE r.BankName IS NULL;


-- Robbers who have never robbed a bank where they hold an account

-- Approach 1: Create a view identifying robbers who have robbed
-- their own bank, then exclude them from the results.
CREATE OR REPLACE VIEW RobbedTheirBank AS
SELECT DISTINCT h.RobberID
FROM HasAccounts h
JOIN Accomplices a ON h.RobberID = a.RobberID AND h.BankName = a.BankName AND h.City = a.City;

SELECT r.RobberID, r.NickName
FROM Robbers r
WHERE r.RobberID NOT IN (SELECT RobberID FROM RobbedTheirBank);

-- Approach 2: Use a nested subquery to exclude robbers who
-- have robbed a bank where they hold an account.
SELECT DISTINCT r.RobberID, r.Nickname
FROM Robbers r
WHERE r.RobberID NOT IN (
    SELECT DISTINCT h.RobberID
    FROM HasAccounts h
    JOIN Accomplices a ON h.RobberID = a.RobberID AND h.BankName = a.BankName AND h.City = a.City
)
ORDER BY r.RobberID;


-- Average earnings per robber in Chicago and the highest-earning other city

-- Approach 1: Use views to calculate robbery totals and robber counts,
-- aggregate these by city, and compare Chicago with the highest other city.
CREATE OR REPLACE VIEW RobberyAmounts AS
SELECT a.BankName, a.City, a.Date, COUNT(DISTINCT a.RobberID) AS NumRobbers, SUM(a.Share) AS TotalAmount
FROM Accomplices a
GROUP BY a.BankName, a.City, a.Date;

CREATE OR REPLACE VIEW CityRobberySummary AS
SELECT City, SUM(TotalAmount) AS CityTotalAmount, SUM(NumRobbers) AS CityTotalRobbers
FROM RobberyAmounts
GROUP BY City;

SELECT City, ROUND((CityTotalAmount / CityTotalRobbers),2) AS AverageShare
FROM CityRobberySummary
WHERE City = 'Chicago'
OR City = (
    SELECT City
    FROM CityRobberySummary
    WHERE City != 'Chicago'
    ORDER BY (CityTotalAmount / CityTotalRobbers) DESC LIMIT 1
);

-- Approach 2: Use nested subqueries and aggregation to calculate
-- the same averages without creating views.
SELECT City, ROUND((SUM(TotalAmount) / SUM(NumRobbers)),2) AS AverageShare
FROM (
    SELECT a.City, a.BankName, a.Date,COUNT(DISTINCT a.RobberID) AS NumRobbers, SUM(a.Share) AS TotalAmount
    FROM Accomplices a
    GROUP BY a.City, a.BankName, a.Date
) AS RobberyAmounts
GROUP BY City
HAVING City = 'Chicago'
OR City = (
    SELECT City
    FROM (
        SELECT a.City, COUNT(DISTINCT a.RobberID) AS NumRobbers, SUM(a.Share) AS TotalAmount
        FROM Accomplices a
        GROUP BY a.City, a.BankName, a.Date
    ) AS InnerRobbery
    GROUP BY City
    HAVING City != 'Chicago'
    ORDER BY (SUM(TotalAmount) / SUM(NumRobbers)) DESC
    LIMIT 1
);


-- Number of robberies and average amount stolen by bank security level

-- Approach 1: Create a view joining robberies with bank security
-- information, then group the results by security level.
CREATE OR REPLACE VIEW RobberiesAndSecurity AS
SELECT r.BankName, r.City, r.Date, r.Amount, b.Security
FROM Robberies r
JOIN Banks b ON r.BankName = b.BankName AND r.City = b.City;

SELECT Security, COUNT(Security) AS NumOfRobberies, ROUND(AVG(Amount), 2) AS AverageStolen
FROM RobberiesAndSecurity
GROUP BY Security;

-- Approach 2: Join the tables and calculate the aggregates
-- directly without creating a view.
SELECT b.Security, COUNT(b.Security) AS NumOfRobberies, ROUND(AVG(r.Amount), 2) AS AverageStolen
FROM Robberies r
JOIN Banks b on r.BankName = b.BankName AND r.City = b.City
GROUP BY Security;
