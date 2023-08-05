-- 1. How many transactions were completed during each marketing campaign?

select campaign_name, count(transaction_id) as Transactions
from transactions  t 
inner join marketing_campaigns  m
      on t.purchase_date between m.start_date and m.end_date
group by campaign_name ;

-- 2. Which product had the highest sales quantity?

select s.product_id, s.product_name,sum(t.quantity) as sales_qty
from  transactions t inner join sustainable_clothing s
      on t.product_id=s.product_id
group by s.product_id,s.product_name
order by sales_qty desc limit 1;

---- 3. What is the total revenue generated from each marketing campaign?

select campaign_name,round(sum(quantity*price),0) as Total_Revenue
from  transactions t inner join sustainable_clothing s
     on t.product_id = s.product_id
     inner join marketing_campaigns m 
     on t.purchase_date between m.start_date 
     and m.end_date 
group by campaign_name;

-- 4. What is the top-selling product category based on the total revenue generated?

select category ,round(sum(quantity*price),0) as Total_Revenue
from  transactions t   join sustainable_clothing s
     on t.product_id = s.product_id
group by category 
order by Total_Revenue desc limit 1;


with cte1 as (
select category ,round(sum(quantity*price),0) as Total_Revenue
from  transactions t   join sustainable_clothing s
     on t.product_id = s.product_id
group by category 
)
select * from cte1
where Total_Revenue = (select max(Total_Revenue) from cte1);

-- 5. Which products had a higher quantity sold compared to the average quantity sold?

with cte1 as(
select distinct product_id,sum(quantity) as qty 
from  marketing_db.transactions
group by product_id 
order by product_id asc)

select s.product_id, product_name,qty 
from cte1 c inner join sustainable_clothing s 
     on c.product_id= s.product_id 
where  qty>(select avg(qty )from cte1);


-- 6. What is the average revenue generated per day during the marketing campaigns?

select m.product_id,campaign_name,purchase_date,round(avg((price*quantity)) , 2)as Avg_Revenue from transactions t inner join sustainable_clothing s
on t.product_id=s.product_id
inner join marketing_campaigns m
on purchase_date between start_date and end_date and m.product_id=t.product_id 
group by campaign_name,purchase_date , m.product_id;

with cte1 as (
select campaign_name ,t.product_id, product_name,quantity,price ,purchase_date , round((quantity*price),2 ) as amount 
from transactions t inner join marketing_campaigns m on t.purchase_date between m.start_date and m.end_date 
       inner join sustainable_clothing s on s.product_id= m.product_id )
select distinct purchase_date ,  round(avg(amount),2) as avg_revenue from cte1 
group by purchase_date order by purchase_date asc;


-- 7. What is the percentage contribution of each product to the total revenue?

with cte1 as( 
select product_name , round((quantity*price) ,2) as Revenue
 from transactions t inner join sustainable_clothing s on t.product_id= s.product_id),
cte2 as (
select round(sum(Revenue),2) as Total_Revenue from cte1)

select cte1.Product_name , round(sum((cte1.Revenue*100/Total_Revenue )),2) as pct_cnt 
from cte1 ,cte2  group by product_name order by pct_cnt desc ;

-- 8. Compare the average quantity sold during marketing campaigns to outside the marketing campaigns
with cte1 as(
select avg(quantity) as Avg_Total_Qty from transactions),
cte2 as(
select avg(quantity) as Avg_Qty_of_Marketing 
from transactions t  inner join marketing_campaigns m 
  on t.purchase_date between m.start_date and m.end_date)

select Avg_Total_Qty,Avg_Qty_of_Marketing ,(Avg_Total_Qty-Avg_Qty_of_Marketing) as Avg_of_Outside_marketing
from cte1,cte2;

-- 9. Compare the revenue generated by products inside the marketing campaigns to outside the campaigns

with cte1 as(
select Round(sum((quantity*price)),2)as Total_Revenue 
from transactions t inner join sustainable_clothing s 
on t.product_id=s.product_id 
),
cte2 as(
select Round(sum((quantity*price)),2) as Market_Campaign_Revenue 
from transactions t  inner join sustainable_clothing s 
    on t.product_id=s.product_id inner join marketing_campaigns m 
    on t.purchase_date between m.start_date and m.end_date
   )

select Total_Revenue,Market_Campaign_Revenue ,(Total_Revenue-Market_Campaign_Revenue) as Outside_marketing_revenue
from cte1,cte2;

-- 10. Rank the products by their average daily quantity sold

with cte1 as(
select purchase_date,product_name ,quantity, sum(quantity) over (partition by purchase_date)  as Total_Qty 
from transactions t inner join sustainable_clothing s on t.product_id=s.product_id 
 ),
cte2 as(
select distinct product_name, round(Avg(Total_Qty) over (partition by product_name),0) as Avg_Qty from cte1 )

select* , dense_rank() over (order by Avg_Qty desc) as rnk  from cte2 ;


