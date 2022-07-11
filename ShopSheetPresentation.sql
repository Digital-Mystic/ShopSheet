USE ShopSheet;

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

-- Run Query including calling Stored Function

SELECT Client_ID AS Client, Total_Sales, Client_Status(total_sales) AS Client_Status
FROM Contracts
ORDER BY Total_Sales DESC;


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

-- Demo for presentation to add Alex to the DB

CALL InsertEmployeeInfo (114, 'Alex', 'Vasile', 'M', '1978-02-05', 86000, 101, '3');

-- Run query to check Alex is in the DB

SELECT *
FROM Employee
WHERE First_Name = 'Alex';

-- CROSS JOIN VIEW - connecting 2 or more tables

-- View showing relation between Contracts/Clients/Employees tables
-- Coalesce function added to remove NULL values. 
-- Use not equal to operator to remove £0 values in the query. 
-- limiting to 5 values in descending order

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