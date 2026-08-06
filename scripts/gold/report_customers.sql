/* Customer Report */ 
CREATE VIEW gold.report_customer as
WITH base_query as
(select
fs.order_number ,
fs.product_key,
fs.order_date,
fs.sales_amount,
fs.quantity,
dc.customer_key,
dc.customer_number,
concat(dc.first_name,' ',dc.last_name) as customer_name ,
DATEDIFF( YEAR,dc.birth_date,GETDATE()) AS age 
from gold.dim_customers dc 
 join gold.fact_sales fs
on dc.customer_key =  fs.customer_key
where order_date is not null)

,customer_aggregation as (
select customer_key,
customer_number,
customer_name,
age,
min(order_date) as first_order_date,
max(order_date) as last_order_date,
COUNT(DISTINCT order_number)as total_orders,
sum(sales_amount) as total_customer_spending ,
sum(quantity)as total_quantity ,
COUNT(DISTINCT Product_key)as total_products,
DATEDIFF(month ,min(order_date),max(order_date))as customer_life_span
from base_query
group by customer_key,
customer_number,
customer_name,
age
)

select *,
CASE
    WHEN recency <= 3 THEN 'Active'
    WHEN recency <= 6 THEN 'At Risk'
    ELSE 'Inactive'
END AS customer_status,
DATEDIFF(MONTH,last_order_date,getdate()) as recency,
CASE WHEN  age<20  THEN  'Under 20'
WHEN age between 20 and 29 THEN  '20-29'
WHEN age between 30 and 39 THEN  '30-39'
WHEN age between 40 and 49 THEN  '40-49'
else '50 and above'
END as age_group, 

CASE WHEN  total_customer_spending>5000 and customer_life_span>=12 THEN  'VIP'
WHEN total_customer_spending <= 5000 and customer_life_span>=12  THEN  'REGULAR'
else 'NEW'
end customer_segment,

---avg AVO 
CASE WHEN  total_customer_spending=0  THEN  0
else total_customer_spending/total_orders
END as average_order_value ,
---avg monthly spent 
 CASE WHEN  customer_life_span =0  THEN total_customer_spending
else total_customer_spending/customer_life_span
END as average_monthly_spent 
from customer_aggregation