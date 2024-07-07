SELECT * from `coffee shop sales`;
-- data cleaning 
-- changed the datatype of transaction_date 
UPDATE `coffee shop sales`
SET transaction_date = STR_TO_DATE(transaction_date, '%d/%m/%Y');
ALTER TABLE `coffee shop sales`
MODIFY COLUMN transaction_date DATE;

DESCRIBE `coffee shop sales`;-- check 

-- changed the datatype of transaction_time
UPDATE `coffee shop sales`
SET transaction_time= STR_TO_DATE(transaction_time, '%H: %i: %s');
ALTER TABLE `coffee shop sales`
MODIFY COLUMN transaction_time TIME;

DESCRIBE `coffee shop sales`;-- check 

-- change the field name

SELECT* FROM `coffee shop sales`;
ALTER TABLE `coffee shop sales`
CHANGE COLUMN ï»¿transaction_id transaction_id INT; 

SELECT* FROM `coffee shop sales`; -- check 
DESCRIBE `coffee shop sales`;-- check 

-- business requirement check 

-- calculate the total sales for may month 
SELECT ROUND(SUM(transaction_qty * unit_price),1) as Total_sales 
FROM `coffee shop sales`
where month(transaction_date) = 5; -- FOR may =5

-- difference in sales t and t-1 and month and month increase and decrease in sales. 
SELECT Month (transaction_date) as month , ROUND(SUM(transaction_qty * unit_price),1) as Total_sales, 
(SUM(transaction_qty * unit_price)- LAG(SUM(transaction_qty * unit_price), 1)  
 OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty * unit_price), 1) 
 OVER (ORDER BY MONTH(transaction_date))*100 as mom_increase_percentage
FROM `coffee shop sales`
WHERE Month (transaction_date) IN(1,2,3,4,5)
GROUP BY  Month (transaction_date)
ORDER BY Month (transaction_date);

-- total number or order in respective month 
SELECT month(transaction_date) as month, count(transaction_id)  as total_order
from `coffee shop sales`
where month(transaction_date) IN (1,2,3,4,5)
group by month(transaction_date);

-- month on month increase or decreaase in number of order 
SELECT month(transaction_date) as month, count(transaction_id)  as total_order,
(count(transaction_id) -lag(count(transaction_id),1) OVER( ORDER BY month(transaction_date)))/ lag(count(transaction_id),1) OVER( ORDER BY month(transaction_date) ) *100 AS mom_change_inorder
from `coffee shop sales`
group by month(transaction_date);

-- total qty sold in respective month 
SELECT* FROM `coffee shop sales`;
SELECT month(transaction_date) as month, sum(transaction_qty)  as total_qty
from `coffee shop sales`
where month(transaction_date) IN (1,2,3,4,5)
group by month(transaction_date);

-- total qty sold in respective month over month 
SELECT month(transaction_date) as month, sum(transaction_qty)  as total_qty,
(sum(transaction_qty) -lag(sum(transaction_qty),1) OVER( ORDER BY month(transaction_date)))/ lag(sum(transaction_qty),1) OVER( ORDER BY month(transaction_date) ) *100 AS mom_change_inorder
from `coffee shop sales`
group by month(transaction_date);

-- sales analysis by weekdays(mon-friday) and weekend (sat=7 and sunday =1)
SELECT  month(transaction_date) AS MONTH,
CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'WEEKENDS'
ELSE 'WEEKDAYS'
END AS day_type,
SUM(unit_price*transaction_qty) As Total_sales 
FROM `coffee shop sales`
WHERE month(transaction_date) in (1,2,3,4,5)
GROUP BY
CASE WHEN DAYOFWEEK(transaction_date) IN (1,7) THEN 'WEEKENDS'
ELSE 'WEEKDAYS'
END,month(transaction_date);

-- average total sales every month 
SELECT month(transaction_date) as month ,AVG(total_sales) as avg_sales 
from
(
SELECT transaction_date, sum(transaction_qty *unit_price) as total_sales
from `coffee shop sales`
where month(transaction_date) in (1,2,3,4,5)
group by transaction_date
) as internal_query
group by month(transaction_date);


-- average sales for may
select avg(total_sales) as avg_sales from 
(select sum(transaction_qty *unit_price) as total_sales
from `coffee shop sales`
where month(transaction_date) = 5
group by transaction_date
) as internal_q


-- daily sales for may 
SELECT 
  day_of_the_month, 
  total_sales,
  CASE 
    WHEN total_sales > avg_sales THEN 'Above Average'
    WHEN total_sales < avg_sales THEN 'Below Average'
    ELSE 'Average'
  END AS sales_status
FROM (
  SELECT 
    DAY(transaction_date) AS day_of_the_month, 
    SUM(transaction_qty * unit_price) AS total_sales, 
    AVG(SUM(transaction_qty * unit_price)) OVER() AS avg_sales
  FROM `coffee shop sales`
  WHERE MONTH(transaction_date) = 5
  GROUP BY transaction_date
) AS sales_data;

--- sales_status by day and month 
SELECT 
  day_of_the_month, 
  month(transaction_date),
  total_sales,
    CASE 
    WHEN total_sales > avg_sales THEN 'Above Average'
    WHEN total_sales < avg_sales THEN 'Below Average'
    ELSE 'Average'
  END AS sales_status
FROM (
  SELECT 
    DAY(transaction_date) AS day_of_the_month, 
    transaction_date,
    SUM(transaction_qty * unit_price) AS total_sales, 
    AVG(SUM(transaction_qty * unit_price)) OVER() AS avg_sales
  FROM `coffee shop sales`
  GROUP BY transaction_date
) AS sales_data;

-- total_sales by month and day of the week 
select month(transaction_date) as month,
case 
when dayofweek(transaction_date)=2 Then "Monday"
when dayofweek(transaction_date)=3 Then "Tuesday"
when dayofweek(transaction_date)=4 Then "Wednesday"
when dayofweek(transaction_date)=5 Then "Thursday"
when dayofweek(transaction_date)=6 Then "Friday"
when dayofweek(transaction_date)=7 Then "Saturday"
ELSE "Sunday"
END AS Day_of_week, 
sum(unit_price*transaction_qty) as Total_sales
from `coffee shop sales`
Group by transaction_date 
Order by month(transaction_date);



