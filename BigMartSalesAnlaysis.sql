CREATE DATABASE bigmart;
USE bigmart;
CREATE TABLE Train (
    Item_Identifier VARCHAR(20),
    Item_Weight FLOAT,
    Item_Fat_Content VARCHAR(20),
    Item_Visibility FLOAT,
    Item_Type VARCHAR(50),
    Item_MRP FLOAT,
    Outlet_Identifier VARCHAR(20),
    Outlet_Establishment_Year INT,
    Outlet_Size VARCHAR(20),
    Outlet_Location_Type VARCHAR(20),
    Outlet_Type VARCHAR(30),
    Item_Outlet_Sales FLOAT
);
SELECT * 
FROM Train;
-- Feature Engineering
CREATE TABLE Train_Processed AS
SELECT * FROM Train;
-- handle missing values
UPDATE Train_Processed
SET Item_Weight = (
    SELECT AVG(Item_Weight) 
    FROM Train_Processed
    WHERE Item_Weight IS NOT NULL
)
WHERE Item_Weight IS NULL;
SET SQL_SAFE_UPDATES = 0;
-- create a new feature
DESCRIBE Train_Processed;
UPDATE Train_Processed
SET Outlet_Age = 2024 - Outlet_Establishment_Year
WHERE Outlet_Establishment_Year IS NOT NULL;
ALTER TABLE Train_Processed ADD COLUMN Price_Per_Visibility FLOAT;
UPDATE Train_Processed
SET Price_Per_Visibility = 
    CASE
        WHEN Item_Visibility = 0 THEN NULL
        ELSE Item_MRP / Item_Visibility
    END;
UPDATE Train_Processed
SET Item_Fat_Content = 'Low Fat'
WHERE Item_Fat_Content IN ('low fat', 'LF');
UPDATE Train_Processed
SET Item_Fat_Content = 'Regular'
WHERE Item_Fat_Content = 'reg';

-- Aggregation for outlet level analysis
-- total sales per outlet
SELECT Outlet_Identifier, SUM(Item_Outlet_Sales) AS Total_Sales
FROM Train_Processed
GROUP BY Outlet_Identifier
ORDER BY Total_Sales DESC;

-- average sales per outlet
SELECT Item_Type, AVG(Item_Outlet_Sales) AS Avg_Sales
FROM Train_Processed
GROUP BY Item_Type
ORDER BY Avg_Sales DESC;

-- Total Number of Items Sold by Outlet Type
SELECT Outlet_Type, COUNT(*) AS Total_Items_Sold
FROM Train_Processed
GROUP BY Outlet_Type
ORDER BY Total_Items_Sold DESC;

 #5. Encoding Categorical Variables
 ALTER TABLE Train_Processed ADD COLUMN Outlet_Size_Num INT;

UPDATE Train_Processed
SET Outlet_Size_Num = 
    CASE
        WHEN Outlet_Size = 'Small' THEN 1
        WHEN Outlet_Size = 'Medium' THEN 2
        WHEN Outlet_Size = 'Large' THEN 3
        ELSE NULL
    END;
    
# Encode Outlet_Location_Type
ALTER TABLE Train_Processed ADD COLUMN Outlet_Location_Num INT;

UPDATE Train_Processed
SET Outlet_Location_Num = 
    CASE
        WHEN Outlet_Location_Type = 'Tier 1' THEN 1
        WHEN Outlet_Location_Type = 'Tier 2' THEN 2
        WHEN Outlet_Location_Type = 'Tier 3' THEN 3
        ELSE NULL
    END;
    
#6. Outlier detection
SELECT *
FROM Train_Processed
WHERE Item_Visibility > (
    SELECT AVG(Item_Visibility) + 2 * STD(Item_Visibility)
    FROM Train_Processed
);
#  Detect Price Outliers
SELECT *
FROM Train_Processed
WHERE Item_MRP > (
    SELECT AVG(Item_MRP) + 2 * STD(Item_MRP)
    FROM Train_Processed
);

# 7. Normalize or Scale Features
ALTER TABLE Train_Processed ADD COLUMN Normalized_Visibility FLOAT;

-- Get the min and max values for Item_Visibility
SELECT MIN(Item_Visibility) AS min_visibility, MAX(Item_Visibility) AS max_visibility
FROM Train_Processed;
-- Declare the variables for min and max visibility
SET @min_visibility = (SELECT MIN(Item_Visibility) FROM Train_Processed);
SET @max_visibility = (SELECT MAX(Item_Visibility) FROM Train_Processed);

-- Update the Normalized_Visibility column
UPDATE Train_Processed
SET Normalized_Visibility = (Item_Visibility - @min_visibility) / (@max_visibility - @min_visibility)
WHERE Item_Visibility IS NOT NULL;

#8. Validate the Feature Engineering Process
SELECT * 
FROM Train_Processed 
LIMIT 10;











