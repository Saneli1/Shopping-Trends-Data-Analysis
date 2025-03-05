##Age distribution of customers.
SELECT  
    CASE  
        WHEN Age BETWEEN 13 AND 19 THEN 'Teens (13-19)'  
        WHEN Age BETWEEN 20 AND 29 THEN 'Young Adults (20-29)'  
        WHEN Age BETWEEN 30 AND 49 THEN 'Adults (30-49)'  
        WHEN Age BETWEEN 50 AND 64 THEN 'Middle-Aged (50-64)'  
        ELSE 'Seniors (65+)'  
    END AS Age_Group,  
    COUNT(*) AS Customer_Count  
FROM shopping_trends.shopping_trends  
GROUP BY Age_Group  
ORDER BY Age_Group;

##Most common age group making purchases.
SELECT Gender, COUNT(*) AS Customer_Count
FROM shopping_trends.shopping_trends 
GROUP BY Gender;

##Gender-based purchasing trends.
SELECT  
    CASE  
        WHEN Age BETWEEN 13 AND 19 THEN 'Teens (13-19)'  
        WHEN Age BETWEEN 20 AND 29 THEN 'Young Adults (20-29)'  
        WHEN Age BETWEEN 30 AND 49 THEN 'Adults (30-49)'  
        WHEN Age BETWEEN 50 AND 64 THEN 'Middle-Aged (50-64)'  
        ELSE 'Seniors (65+)'  
    END AS Age_Group,  
    COUNT(*) AS Customer_Count  
FROM shopping_trends.shopping_trends 
GROUP BY Age_Group
ORDER BY Customer_count DESC;

##Top 5 most purchased items.
SELECT `Item Purchased`, COUNT(*) AS Item_Count
FROM shopping_trends.shopping_trends 
GROUP BY `Item Purchased`
ORDER BY Item_Count DESC
LIMIT 5;

##Least popular products.
SELECT `Item Purchased`, COUNT(*) AS Item_Count
FROM shopping_trends.shopping_trends 
GROUP BY `Item Purchased`
ORDER BY Item_Count ASC;

##Categories with the highest sales.
SELECT Category ,SUM(`Purchase Amount (USD)`) AS Total_Sales, COUNT(*) AS Category_Count
FROM shopping_trends.shopping_trends 
GROUP BY Category
ORDER BY Total_Sales DESC;

##Total revenue from all purchases.
SELECT SUM(`Purchase Amount (USD)`) AS Total_Revenue
FROM shopping_trends.shopping_trends ;

##Average purchase amount per transaction.
SELECT AVG(`Purchase Amount (USD)`) AS Avg_Purch_Amt
FROM shopping_trends.shopping_trends ;

##Highest and lowest spending customers.
(SELECT `Customer ID`, SUM(`Purchase Amount (USD)`) AS Total_Purch
FROM shopping_trends.shopping_trends 
GROUP BY `Customer ID`
ORDER BY Total_Purch DESC
LIMIT 1)
UNION 
(SELECT `Customer ID`, SUM(`Purchase Amount (USD)`) AS Total_Purch
FROM shopping_trends.shopping_trends 
GROUP BY `Customer ID`
ORDER BY Total_Purch ASC
LIMIT 1);
##States with the highest and lowest sales.
(SELECT `Location`, SUM(`Purchase Amount (USD)`) AS Total_Purch
FROM shopping_trends.shopping_trends 
GROUP BY `Location`
ORDER BY Total_Purch ASC
LIMIT 1)
UNION
(SELECT `Location`, SUM(`Purchase Amount (USD)`) AS Total_Purch
FROM shopping_trends.shopping_trends 
GROUP BY `Location`
ORDER BY Total_Purch DESC
LIMIT 1);

##category with the most purchases in each state.
WITH RankedCategories AS (
    SELECT 
        Location, 
        Category, 
        COUNT(*) AS Total_Purchases,
        RANK() OVER (PARTITION BY Location ORDER BY COUNT(*) DESC) AS `Rank`
    FROM shopping_trends.shopping_trends
    GROUP BY Location, Category
)
SELECT Location, Category, Total_Purchases
FROM RankedCategories
WHERE `Rank` = 1;
##Most purchased items in each season.
SELECT `Item Purchased`, COUNT(*) AS Purch_Items, Season
FROM shopping_trends.shopping_trends
GROUP BY  `Item Purchased`, Season
ORDER BY Purch_Items DESC;

##Does seasonality impact spending behavior?
##part1 ; Total spending per season
SELECT SUM(`Purchase Amount (USD)`) AS Tot_Purch, Season
FROM shopping_trends.shopping_trends
GROUP BY  Season
ORDER BY Tot_Purch DESC;
##part2 ; Average Purchase Amount Per Season
SELECT AVG(`Purchase Amount (USD)`) AS Average, Season
FROM shopping_trends.shopping_trends
GROUP BY Season
ORDER BY Average DESC;

##part3; ## Count the Number of Transactions Per Season
SELECT Season, COUNT(*) AS Tot_Purch
FROM shopping_trends.shopping_trends
GROUP BY Season
ORDER BY Tot_Purch;


##Do higher-rated products get purchased more often?
SELECT `Review Rating`,  COUNT(*) AS Purchase_Counts, SUM(`Purchase Amount (USD)`) AS Tot_Spending
FROM shopping_trends.shopping_trends
GROUP BY `Review Rating`
ORDER BY Purchase_Counts DESC;

##Do lower-rated products get purchased less often?
SELECT `Review Rating`,  COUNT(*) AS Purchase_Counts, SUM(`Purchase Amount (USD)`) AS Tot_Spending
FROM shopping_trends.shopping_trends
GROUP BY `Review Rating`
ORDER BY Purchase_Counts ASC;

##People tend to purchase higher-rated products more often, as indicated by the purchase counts and total spending

##Most preferred payment method.
SELECT `Payment Method`, Count(*) AS Method_Count
FROM shopping_trends.shopping_trends
GROUP BY `Payment Method`
ORDER BY Method_Count DESC;

##Effect of discounts on purchase behavior.
##part1; Check how many purchases happened with and without discounts.
SELECT `Discount Applied`, COUNT(*) AS Total_Transactions
FROM shopping_trends.shopping_trends
GROUP BY `Discount Applied`;

##part2; Average Purchase Amount Per Transaction:
SELECT `Discount Applied`, AVG(`Purchase Amount (USD)`) AS Avg_Purch
FROM shopping_trends.shopping_trends
GROUP BY `Discount Applied`;

##part 3; alculate the percentage change in purchase frequency between discounted and non-discounted purchases
WITH Discounted AS (
    SELECT `Frequency of Purchases`, COUNT(*) AS Discounted_Count
    FROM shopping_trends.shopping_trends
    WHERE `Discount Applied` = 'Yes'
    GROUP BY `Frequency of Purchases`
),
NonDiscounted AS (
    SELECT `Frequency of Purchases`, COUNT(*) AS Non_Discounted_Count -- FIX: Changed alias name
    FROM shopping_trends.shopping_trends
    WHERE `Discount Applied` = 'No'
    GROUP BY `Frequency of Purchases`
)
SELECT 
    d.`Frequency of Purchases`, 
    d.Discounted_Count, 
    nd.Non_Discounted_Count, 
    ROUND(((d.Discounted_Count - nd.Non_Discounted_Count) / nd.Non_Discounted_Count) * 100, 2) AS Percentage_Change
FROM Discounted d
JOIN NonDiscounted nd
ON d.`Frequency of Purchases` = nd.`Frequency of Purchases`
ORDER BY Percentage_Change DESC;
##discounted items are purhcased less frequently than non-discounted items. 

## tot revenue from purchases where a promo code was used,
SELECT SUM(`Purchase Amount (USD)`) AS Tot_Purch, Category, `Promo Code Used`
 FROM shopping_trends.shopping_trends
 WHERE `Promo Code Used` = 'Yes'
 GROUP BY Category;
 
 ##Which shipping type is most popular?
 SELECT `Shipping Type`, COUNT(*) AS Tot_Shipping
 FROM shopping_trends.shopping_trends
 GROUP BY `Shipping Type`
 ORDER BY Tot_Shipping DESC;
 
 ##How many customers are subscribed to loyalty programs?
 SELECT  COUNT(DISTINCT `Customer ID`) AS Tot_Customers
 FROM shopping_trends.shopping_trends
 WHERE `Subscription Status` =  'Yes';
 
 ##How does subscription status affect purchase frequency?
 ##part 1 ; Compare Total Purchases
 SELECT SUM(`Purchase Amount (USD)`) AS Tot_Purch, `Subscription Status`
  FROM shopping_trends.shopping_trends
  GROUP BY `Subscription Status`
  ORDER BY Tot_Purch;
##part 2 ; Compare Average Purchase Frequency
SELECT  `Subscription Status`,
AVG (CASE
WHEN `Frequency of Purchases` = 'Daily' THEN 30
WHEN `Frequency of Purchases` = 'Weekly' THEN 4
WHEN `Frequency of Purchases` = 'Fortnightly' THEN 2
WHEN `Frequency of Purchases` = 'Monthly' THEN 1
WHEN `Frequency of Purchases` = 'Quarterly' THEN 0.33
WHEN `Frequency of Purchases` = 'Annually' THEN 0.08
ELSE 0
END) AS Avg_Purch_Freq, COUNT(DISTINCT `Customer ID`) AS Tot_Customers
FROM shopping_trends.shopping_trends
GROUP BY  `Subscription Status`
ORDER BY Tot_Customers DESC;
##Subscribers purchase slightly more often
##More non-subscribers exist

##Compare Total Spending
SELECT `Subscription Status`, 
       SUM(`Purchase Amount (USD)`) AS Total_Spending, 
       COUNT(DISTINCT `Customer ID`) AS Tot_Cus
FROM shopping_trends.shopping_trends
GROUP BY `Subscription Status`
ORDER BY Total_Spending DESC;
##There are more non-subscribed customers than subscribed customers.
##Non subscribed cus spend more overall.

##Compare High-Frequency Shoppers
SELECT 
    `Subscription Status`, 
    `Frequency of Purchases`, 
    COUNT(DISTINCT `Customer ID`) AS Tot_Cus, 
    SUM(`Purchase Amount (USD)`) AS Total_Spending
FROM shopping_trends.shopping_trends
GROUP BY `Subscription Status`, `Frequency of Purchases`
ORDER BY `Subscription Status` DESC, Total_Spending DESC;

##Check Purchase Trends Over Time
SELECT category, `Subscription Status`, 
       SUM(`Purchase Amount (USD)`) AS Tot_Spending, 
       Season, 
       COUNT(*) AS Tot_Seas, 
       AVG(`Purchase Amount (USD)`) AS Avg_Spending
FROM shopping_trends.shopping_trends
GROUP BY `Subscription Status`, category, Season
ORDER BY Tot_Spending;
