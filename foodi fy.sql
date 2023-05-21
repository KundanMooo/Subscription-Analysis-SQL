CREATE SCHEMA dbo;
SET search_path = dbo;

CREATE TABLE plans (
  plan_id INTEGER,
  plan_name VARCHAR(13),
  price DECIMAL(5,2)
);

INSERT INTO plans
  (plan_id, plan_name, price)
VALUES
  ('0', 'trial', '0'),
  ('1', 'basic monthly', '9.90'),
  ('2', 'pro monthly', '19.90'),
  ('3', 'pro annual', '199'),
  ('4', 'churn', null);


             
CREATE TABLE subscriptions (
  customer_id INTEGER,
  plan_id INTEGER,
  start_date DATE
);

INSERT INTO subscriptions
  (customer_id, plan_id, start_date)
VALUES
  ('1', '0', '2020-08-01'),
  ('1', '1', '2020-08-08'),
  ('2', '0', '2020-09-20'),
  ('2', '3', '2020-09-27'),
  ('3', '0', '2020-01-13'),
  ('3', '1', '2020-01-20'),
  ('4', '0', '2020-01-17'),
  ('4', '1', '2020-01-24'),
  ('4', '4', '2020-04-21'),
  ('5', '0', '2020-08-03'),
  ('5', '1', '2020-08-10'),
  ('6', '0', '2020-12-23');
  
--1.How many customers has foodie-fi ever had?
select count(distinct customer_id)  from dbo.subscriptions

--2.What is the monthly distribution of trial plan?
SELECT EXTRACT(MONTH FROM start_date) AS month, COUNT(plan_id)
FROM dbo.subscriptions
WHERE plan_id = '0'
GROUP BY 1
ORDER BY 1;

--3.Show the breakdown by count of events for each plan_name after the year 2020
select plan_id,count(*)
from
dbo.subscriptions
where extract(year from start_date)>2020
group by 1
order by 1

--4.What is the customer count and percentage of customers who have churned rounded to 1 decimal place
select 
count(*) as count_of_customer_churn,
concat((count(*)*100)/(select count(distinct customer_id) from dbo.subscriptions),'%') as perc_of_customer_churn
from 
dbo.subscriptions
where plan_id=4;

--5.What is the number and percentage of customer plans after their initial free trial?
with cte as 
(select
plan_id,ROW_NUMBER() over(partition by customer_id order by start_date) as plan_after_trial
from dbo.subscriptions)
select plan_id ,count(*)
from cte
where plan_after_trial=2
group by 1


--7.What is the customer count and percentage breakdown of all latest plans?
with cte as 
(select
plan_id,ROW_NUMBER() over(partition by customer_id order by start_date) as plan_after_trial
from dbo.subscriptions)
select plan_id ,count(*) as cust_count_in_eachplan,concat((count(*)*100)/(select count(distinct customer_id)  from dbo.subscriptions),'%') as perc_in_each_plan
from cte
where plan_after_trial=2
group by 1


--10.How many customers downgraded from a pro-monthly to a basic monthly plan ?
with cte as (
select 
customer_id,
plan_id,
lead(plan_id,1) over(partition by customer_id order by start_date) as next_plan
from dbo.subscriptions)
select count(*)
from cte 
where plan_id=2 and next_plan=1