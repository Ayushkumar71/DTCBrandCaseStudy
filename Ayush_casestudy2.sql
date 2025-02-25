


----------- BASIC EDA & PROCESSING --------------
--------------------------------------------------



-- Show metadata of our tables in the dataaset
SELECT
  table_name
FROM
  `abstract-key-415803`.`jarassignment`.`INFORMATION_SCHEMA.TABLES`;



-- Show columns in sales table
SELECT 
  *
FROM 
  `abstract-key-415803`.`jarassignment`.`INFORMATION_SCHEMA.COLUMNS`;



-- Exploring values, Notices opportunity to Transform profit field by introducing a new column 
SELECT 
  Amount,
  profit,
  Amount + Profit AS profit_amount_old,
  profit_amount
FROM 
  `jarassignment.order_details`;



-- Examining the order month column in sales target table, Notices opportunity to create a new column order_month.
-- Not trying to convert to DATE format as each entry in `Month of Order Date` is missing the year.
SELECT
  `Month of Order Date`,
  LEFT(`Month of Order Date`, 3) AS order_month,
FROM
  `jarassignment.sales_target`;









-- Adding new column to order_details, inserting actual profit amount
-- ALTER TABLE
--   `jarassignment.order_details`
-- ADD COLUMN 
--     profit_amount INT64;



-- Inserting values into the newly created column
UPDATE
  `abstract-key-415803.jarassignment.order_details`
SET
  profit_amount = 
  CASE
    WHEN Profit > 0 THEN CAST(Profit AS INT64) -- For when the number reflects the actual profit amount
    ELSE CAST(Amount + Profit AS INT64) -- casting from FLOAT64 to INT64
END
WHERE
  True;







-- Adding new column to sales_target, inserting order month
-- ALTER TABLE
--   `jarassignment.sales_target`
-- ADD COLUMN 
--     order_month STRING;



-- Inserting values into the newly created column
UPDATE
  `jarassignment.sales_target`
SET
  order_month = LEFT(`Month of Order Date`, 3)
WHERE
  True;










-------------  Sales and Profitability Analysis  --------------
---------------------------------------------------------------



-- Merge the List of Orders and Order Details datasets on the basis of Order ID.
-- Calculate the total sales (Amount) for each category across all orders.
SELECT
  t1.`category`,
  SUM(t1.`Amount`) AS Total_sales,
FROM
  `abstract-key-415803`.`jarassignment`.`order_list` AS t0
INNER JOIN
  `abstract-key-415803`.`jarassignment`.`order_details` AS t1
ON
  t0.`order ID` = t1.`order ID`
GROUP BY 
  t1.`category`
ORDER BY
  Total_sales DESC;


-- For each category, calculate the average profit per order and total profit margin
-- (profit as a percentage of Amount).

SELECT
  category,
  SUM(profit_amount) / COUNT(`order ID`) AS avg_profit_per_order,
  (SUM(Profit_amount) / SUM(Amount)) * 100 AS profit__margin_percentage,
FROM 
  `jarassignment.order_details`
GROUP BY
  category
ORDER BY
  avg_profit_per_order DESC;



-- Insight driven question here --









---------------  Target Achievement Analysis  -----------------
---------------------------------------------------------------



-- Using the Sales Target dataset, calculate the percentage change in target sales
-- for the Furniture category month-over-month.
SELECT 
  Target - LAG(Target) OVER (ORDER BY `Month of Order Date`) AS target_change,
  ROUND(
    ((Target - LAG(Target) OVER (ORDER BY `Month of Order Date`)) / 
    LAG(Target) OVER (ORDER BY `Month of Order Date`)),
     2
     ) * 100 AS target_percentage_change,
FROM
  `jarassignment.sales_target`
WHERE 
  Category="Furniture";




-- Insight driven question here --









---------------  Regional Performance Insights  ---------------
---------------------------------------------------------------



-- From the List of Orders dataset, identify the top 5 states with the highest order
-- count. For each of these states, calculate the total sales and average profit.
SELECT 
  state,
  COUNT(t0.`Order ID`) AS has_orders,
  SUM(t1.Quantity) AS total_sales,
  ROUND(AVG(t1.profit_amount), 2) AS avg_profit,
FROM 
  `jarassignment.order_list` AS t0
INNER JOIN
  `jarassignment.order_details` AS t1
ON
  t0.`order ID` = t1.`order ID`
GROUP BY
  state
ORDER BY 
  has_orders DESC;



-- Insight driven question here --








