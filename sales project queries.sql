use projects;
select * from sale_dataset;
-- Data cleaning
-- Step 1:- To check for Duplicate 

SELECT transaction_id,COUNT(transaction_id)
FROM sale_dataset
GROUP BY transaction_id
HAVING COUNT(transaction_id) >1;

create table sales as
select distinct * from sale_dataset;

-- Step 2 :- Correction of Headers

SELECT * FROM sales;

alter table sales
rename column quantty to quantity;

alter table sales
rename column prce to price;

-- Step 3 :- To check Datatype

select column_name,data_type
from information_schema.columns
where table_name = 'sales';

-- Step 4 :- To Check Null Values

select * from sales
where transaction_id is null
or 
customer_id is null
or
customer_name is null
or 
customer_age is null
or 
gender is null
or
product_id is null;

-- Step 5:- Data Cleaning

select distinct gender from sales;

update sales
set gender = "Male"
where gender = "M";

update sales
set gender = "Female"
where gender = "F";

select distinct payment_mode
from sales;

update sales
set payment_mode = "Credit Card"
where payment_mode = "CC";

-- Data Analysis--

-- 1. What are the top 5 most selling products by quantity?

select * from sales;

select distinct status from sales;

select product_category,sum(quantity) as total_quantity
from sales
where status = "delivered"
group by product_category
order by total_quantity desc;
-- Business Problem: We don't know which products are most in demand.
-- Business Impact: Helps prioritize stock and boost sales through targeted promotions.

-----------------------------------------------------------------------------------------------------
--  2. Which products are most frequently cancelled?

select * from sales;
select product_name,count(*) as total_cancelled from sales
where status = "cancelled"
group by product_name
order by count(*) desc;

-- Business Problem: Frequent cancellations affect revenue and customer trust.

-- Business Impact: Identify poor-performing products to improve quality or remove from catalog.
-----------------------------------------------------------------------------------------------------------

-- 3. What time of the day has the highest number of purchases?

select * from sales;
select case 
	WHEN HOUR(time_of_purchase) BETWEEN 0 AND 5 THEN 'Night'
    WHEN HOUR(time_of_purchase) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(time_of_purchase) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(time_of_purchase) BETWEEN 18 AND 23 THEN 'Evening'
end as time_bucket,count(*) as total_order
from sales
group by 
case WHEN HOUR(time_of_purchase) BETWEEN 0 AND 5 THEN 'Night'
    WHEN HOUR(time_of_purchase) BETWEEN 6 AND 11 THEN 'Morning'
    WHEN HOUR(time_of_purchase) BETWEEN 12 AND 17 THEN 'Afternoon'
    WHEN HOUR(time_of_purchase) BETWEEN 18 AND 23 THEN 'Evening'
    end
    order by total_order desc;
    
    -- Business Problem Solved: Find peak sales times.

	-- Business Impact: Optimize staffing, promotions, and server loads.
-----------------------------------------------------------------------------------------------
-- 4. Who are the top 5 highest spending customers?

select * from sales;
select customer_name,sum(price*quantity) total_spend from sales
group by customer_name
order by total_spend desc
limit 5;

-- Business Problem Solved: Identify VIP customers.

-- Business Impact: We should give him Personalized offers, loyalty rewards.
-----------------------------------------------------------------------------------------------
-- 5. Which are the top 5 product categories by revenue? (CTE)

WITH category_revenue AS (
    SELECT
        product_category,
        SUM(price * quantity) AS total_revenue
    FROM sales
    WHERE status = 'delivered'
    GROUP BY product_category
)

SELECT
    product_category,
    ROUND(total_revenue, 2) AS total_revenue
FROM category_revenue
ORDER BY total_revenue DESC
LIMIT 5;
-- Business Problem Solved: Identify top-performing product categories.

-- Business Impact: We can invest more on these products and increase there supply
----------------------------------------------------------------------------------------------

--  6. What is the return/cancellation rate per product category?

select * from sales;

select product_category,
count(case when status = "cancelled" then 1 end)*100.0/count(*) as cancel_rate
from sales
group by product_category
order by cancel_rate desc;

select product_category,
count(case when status = "returned" then 1 end)*100.0/count(*) as return_rate
from sales
group by product_category
order by return_rate desc;


-- Business Problem Solved: Monitor dissatisfaction trends per category.

-- Business Impact: Reduce returns, improve product descriptions.
--  and fix product or logistics issues.

--  7. What is the most preferred payment mode?

select payment_mode,count(payment_mode) total_payment from sales
group by payment_mode
order by total_payment desc;

-- Business Problem Solved: Know which payment options customers prefer.

-- Business Impact: Streamline payment processing, prioritize popular modes.
---------------------------------------------------------------------------------------------

--  7. How does age group affect purchasing behavior?

select case
when customer_age between 18 and 25 then "18-25"
when customer_age between 26 and 35 then "26-35"
when customer_age between 36 and 50 then "36-50"
else "51+"
end as age_group, sum(price*quantity) as revenue
from sales
group by case
when customer_age between 18 and 25 then "18-25"
when customer_age between 26 and 35 then "26-35"
when customer_age between 36 and 50 then "36-50"
else "51+"
end
order by revenue desc;

-- Business Problem Solved: Understand customer age_group on purchase .

-- Business Impact: Targeted marketing and product recommendations by age group.
---------------------------------------------------------------------------------------------
--  9. What’s the monthly sales trend?

select month(purchase_date) as month,sum(price*quantity) as revenue from sales
group by month 
order by month ;

-- Business Problem: Sales fluctuations go unnoticed.

-- Business Impact: --Business Problem: Sales fluctuations go unnoticed.


-- Business Problem: Sales fluctuations go unnoticed.

-- Business Impact: if we have idea that which month highest sale so we plan to growing other months..
-----------------------------------------------------------------------------------------------------

-- 10. What is total count of each product by gender

select gender,product_category,count(product_category) from sales
group by gender,product_category
order by  count(product_category) desc ;

-- Bussiness Problem : identify Gender based product performance
-- Bussiness impact : personalized ads gender focused compagin
-----------------------------------------------------------------------------------------------------

-- 11. Rank Product based on revenue

-- 12. Rank products based on total revenue

SELECT
    product_name,
    ROUND(SUM(price * quantity), 2) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(price * quantity) DESC
    ) AS revenue_rank
FROM sales
WHERE status = 'delivered'
GROUP BY product_name
ORDER BY revenue_rank;

-- Business Problem: The business does not know which individual products are contributing the most revenue.
-- Business Impact:
-- Product ranking helps identify high-performing products for inventory planning, promotions, and targeted marketing.

