CREATE DATABASE ShopSheet;

Use ShopSheet;

-- Create 5 tables with Primary Keys, Foreign Keys and AUTOINCREMENT 

CREATE TABLE Employee(
Employee_ID INT PRIMARY KEY auto_increment, 
First_Name VARCHAR(40),
Last_Name VARCHAR(40),
Sex VARCHAR(1),
Date_of_Birth DATE,
Salary INT,
Supervisor_ID INT,
Store_ID INT
);

CREATE TABLE Store(
Store_ID INT PRIMARY KEY,
Store_Name VARCHAR(40),
Store_Manager_ID INT,
Store_Manager_Start_Date DATE,
FOREIGN KEY(Store_Manager_ID) REFERENCES Employee(Employee_ID) ON DELETE SET NULL
);

CREATE TABLE Client(
Client_ID INT PRIMARY KEY,
Client_Name VARCHAR(40),
Store_ID INT,
FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID) ON DELETE SET NULL
);

CREATE TABLE Contracts(
Employee_ID INT,
Client_ID INT,
Total_Sales INT,
PRIMARY KEY(Employee_ID, Client_ID),
FOREIGN KEY(Employee_ID) REFERENCES Employee(Employee_ID) ON DELETE CASCADE,
FOREIGN KEY(Client_ID) REFERENCES Client(Client_ID) ON DELETE CASCADE
);

CREATE TABLE Store_Supplier(
Store_ID INT,
Supplier_Name VARCHAR(40),
Supply_Type VARCHAR(40),
PRIMARY KEY (Store_ID, Supplier_Name),
FOREIGN KEY (Store_ID) REFERENCES Store(Store_ID) ON DELETE CASCADE
);

-- Inserting data into tables

INSERT INTO Employee (
Employee_ID, 
First_Name, 
Last_Name, 
Sex,
Date_of_Birth,
Salary,
Supervisor_ID,
Store_ID
) 
VALUES 
(100,'Matthew', 'Kemp', 'M','1992-07-26', 250000, NULL, 1),
(101, 'Donald', 'Miller', 'M', '2000-05-14', 190000, 100, 1),
(102, 'Natasha', 'Morrison', 'F', '1986-02-28', 190000, 100, 2),
(103, 'Alexandra', 'Smith', 'F', '1999-05-30', 85000, 102, 2),
(104, 'John', 'Ramos', 'M', '2000-06-16', 75000, 102, 2),
(105, 'Ann', 'Williams', '', '1995-03-10', 65000, 102, 3),
(106, 'Tyler', 'Richards', 'F', '1986-10-12', 75000, 103, 2),
(107, 'Shawn', 'Johnson', 'M', '1984-12-17', 99000, 102, 2),
(108, 'David', 'Summers', '', '1993-03-16', 71000, 102, 2),
(109, 'Casey', 'Harper', 'F', '1993-05-05', 65000, 106, 3),
(110, 'Kristine', 'Dunlop', 'F', '1986-10-21', 71000, 106, 3),
(111, 'Brian', 'Stevens', 'M', '1995-09-06', 88000, 107, 3),
(112, 'Pamela', 'Lopez', '', '2002-08-26', 90000, 102, 2);

INSERT INTO Store (
Store_ID,
Store_Name,
Store_Manager_ID,
Store_Manager_Start_Date
)
VALUES
(1, 'Head Office', 100, '2006-05-26'),
(2, 'Woodstock', 102, '2010-01-31'),
(3, 'Greenville', 106, '2020-08-08'),
(4, 'Bellevue', 108, '2021-09-15');

INSERT INTO Client(
Client_ID,
Client_Name,
Store_ID
)
VALUES
(300, 'Fairyspace', 2),
(301, 'Lifeshade', 2),
(302, 'Primesearch', 3),
(303, 'Dinopoint', 3),
(304, 'Fortune Productions', 2),
(305, 'Equinox Corp.', 3),
(306, 'Lemonaid', 2),
(307, 'Lionessolutions', 4);

INSERT INTO Contracts(
Employee_ID,
Client_ID,
Total_Sales
)
VALUES
(105, 300, 65000),
(102, 301, 505000),
(108, 302, 20500),
(107, 303, 4400),
(108, 303, 10600),
(107, 305, 28000),
(105, 304, 36000),
(102, 306, 14000),
(105, 306, 169000);


 INSERT INTO Store_Supplier(
 Store_ID,
 Supplier_Name,
 Supply_Type
 )
 VALUES
 (2, 'Padler', 'Paper'),
 (2, 'Formis', 'Forms'),
 (2, 'Pensila', 'Pens'),
 (3, 'EpiForm', 'Forms'),
 (3, 'PaperRoom', 'Paper'),
 (3, 'Pensila', 'Pens'),
 (4, 'Inkstr', 'Ink'),
 (3, 'Textink', 'Ink'),
 (4, 'EpiForm', 'Forms'),
 (2, 'Handstamp', 'Ink');
 
-- Adding additional Foreign Keys after all tables created

ALTER TABLE Employee
ADD FOREIGN KEY(Supervisor_ID)
REFERENCES Employee(Employee_ID)
ON DELETE SET NULL;

ALTER TABLE Employee
ADD FOREIGN KEY(Store_ID)
REFERENCES Store(Store_ID)
ON DELETE SET NULL;

-- STORED FUNCTION

-- 1. Stored Function to assign specific status to clients based on total sales

DELIMITER //

CREATE FUNCTION Client_status(
	total_sales DECIMAL(10,2)
) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE Client_status VARCHAR(20);

    IF total_sales > 150000 THEN
		SET Client_status = 'Gold';
    ELSEIF (total_sales >= 50000 AND 
			total_sales <= 149999) THEN
        SET Client_status = 'Silver';
    ELSEIF total_sales < 50000 THEN
        SET Client_status = 'Bronze';
    END IF;
	-- return the client_status
	RETURN (Client_status);
END//
DELIMITER ;

-- Calling Stored Function

SELECT Client_ID AS Client, Total_Sales, Client_Status(total_sales) AS Client_Status
FROM Contracts
ORDER BY Total_Sales DESC;

-- JOINS 

-- Cross Join View
-- View showing relation between Contracts/Clients/Employees tables
-- Coalesce added to remove NULL values. 
-- Created 2 views with and without ID numbers 

CREATE VIEW Employee_Contract_Client_Info AS
SELECT E.Employee_ID AS EmployeeID, E.First_Name AS Employee, C.Client_ID AS ClientID, C.Client_Name AS Client,
		COALESCE(
		(SELECT Total_Sales 
        FROM Contracts
        WHERE Employee_ID = E.Employee_ID AND Client_ID = C.Client_ID), 0)
        AS Total_Sales
FROM Employee AS E
CROSS JOIN Client AS C;

-- Query to find all employees who had contracts with clients. Added in comparison operator
-- to remove zero values. 

SELECT * 
FROM Employee_Contract_Client_Info
WHERE Total_Sales != 0;

-- 2. View without ID numbers for easier readability and limiting to 5 values in descending order

CREATE VIEW Employee_Contract_Client_Info_Simple AS
SELECT E.First_Name AS Employee, C.Client_Name AS Client,
		COALESCE(
		(SELECT Total_Sales 
        FROM Contracts
        WHERE Employee_ID = E.Employee_ID AND Client_ID = C.Client_ID), 0)
        AS Total_Sales
FROM Employee AS E
CROSS JOIN Client AS C;

-- Query 

SELECT * 
FROM Employee_Contract_Client_Info_Simple
HAVING Total_Sales != 0
ORDER BY Total_Sales DESC
LIMIT 5; 

-- SUBQUERY - Select the Employee First Name, Last Name, ID, Store from the 
-- employee table where the Employee_ID had total sales over £100,000 from Contracts table.  

-- First I created a Stored Function to Concat First Name and Last name of employees for readability. 
-- Also wanted to see how this style of Stored Function worked. 

CREATE FUNCTION full_name(first_name VARCHAR(40), last_name VARCHAR(40))
RETURNS CHAR(80) DETERMINISTIC
RETURN CONCAT(first_name, ' ', last_name);
-- Check it works!
SELECT full_name(first_name, last_name) AS Employee_Name
FROM Employee;

-- SUBQUERY 

SELECT Full_Name(First_Name, Last_Name) AS Name, Employee_ID AS ID , Store_ID AS Store
FROM Employee
WHERE Employee.Employee_ID IN (
	SELECT Contracts.Employee_ID
    FROM Contracts 
    WHERE Contracts.Total_Sales > 100000
);

-- ADVANCED TOPICS 

-- 1. Stored Procedure - Add new employee to Employee Table

-- Change Delimiter
DELIMITER //
-- Create Stored Procedure
CREATE PROCEDURE InsertEmployeeInfo(
IN Employee_ID INT, 
IN First_Name VARCHAR(40),
IN Last_Name VARCHAR(40),
IN Sex VARCHAR(1),
IN Date_of_Birth DATE,
IN Salary INT,
IN Supervisor_ID INT,
IN Store_ID INT)
BEGIN

INSERT INTO Employee (Employee_ID, First_Name, Last_Name, Sex, Date_of_Birth, Salary, Supervisor_ID, Store_ID)
VALUES (Employee_ID, First_Name, Last_Name, Sex, Date_of_Birth, Salary, Supervisor_ID, Store_ID);

END//
-- Change Delimiter again
DELIMITER ;

-- This is one I did already: 

CALL InsertEmployeeInfo (113, 'Kyle', 'Howard', '', '1980-05-30', 71000, 102, 2);

-- Check that 'Kyle' is in the DB

SELECT *
FROM Employee
WHERE First_Name = 'Kyle';

-- Demo for presentation to add Alex to the DB

CALL InsertEmployeeInfo (114, 'Alex', 'Vasile', 'M', '1978-02-05', 86000, 101, '3');

-- Check Alex is in the DB

SELECT *
FROM Employee
WHERE First_Name = 'Alex';

-- 2. VIEW - Create a view using 3-4 base tables to run a query
-- Find Employee ID's who had total sales > £100,000 per client

CREATE VIEW Employee_Total_Sales_Greater_100K_per_client AS
SELECT Employee.Employee_ID AS Employee, Contracts.Total_Sales AS Sales, Client.Client_Name AS Client
FROM Client
INNER JOIN Contracts 
ON Client.Client_ID = Contracts.Client_ID 
INNER JOIN Employee 
ON Contracts.Employee_ID = Employee.Employee_ID
WHERE Employee.Employee_ID IN
	(SELECT Employee_ID
    FROM Contracts
    HAVING Total_Sales >= 100000)
ORDER BY Employee.Employee_ID; 

-- Query

SELECT * 
FROM Employee_Total_Sales_Greater_100K_per_client;


-- 3. HAVING and GROUP BY. Finding the average total sales 
-- where total sales < £50,000 per client

SELECT Client_ID, ROUND(AVG(Total_Sales), 2) AS AVG_Total_Sales
FROM Contracts
GROUP BY Client_ID
HAVING AVG(Total_Sales) < 50000 
ORDER BY AVG(Total_Sales) DESC;

-- Checking the above by only looking at client ID 303. Should equate to 2 sales less than £50,000

SELECT Client_ID, Total_Sales 
FROM Contracts
WHERE Client_ID = 303;

-- Has 2 sales - £4,400 and £10,600 which totals £15,000 which averages at £7500

SELECT ROUND(AVG(Total_Sales),2) AS AVG_Total_Sales
FROM Contracts
WHERE Client_ID = 303;

-- END --