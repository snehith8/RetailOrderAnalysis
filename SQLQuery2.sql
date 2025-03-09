-- find top 10 highest revenve
select top 10 product_id ,sum(sale_price)AS sales
From snehith.dbo.df_orders
Group by product_id 
order by sales desc;

-- find top 5 highest sellinf products in each region
with cte as(
select  region,product_id,SUM(sale_price) AS sales
From snehith.dbo.df_orders
GROUP BY region,product_id)
select * from(
select*,row_number() over(
partition by region
order by region,sales desc)as rn
from cte) A
WHERE rn<6;

-- find month over growth comparision from 2022 to 2023
with cte as(
select year(order_date)  as _year_ , month(order_date) as _month_ ,sum(sale_price)  AS sales 
from snehith.dbo.df_orders
group by year(order_date), month(order_date)
--order by year(order_date), month(order_date)
)
select _month_ ,sum(case when _year_=2022 then sales else 0 end ) as sales_2022 , sum(case when _year_=2023 then sales else 0 end) as sales_2023
from cte 
group by _month_
order by _month_

--find each catogory which month had highest sales

with cte as(
select category ,FORMAT(order_date,'yyyy MM') as order_year_month ,sum(sale_price) as sales
from snehith.dbo.df_orders
group by category, FORMAT(order_date,'yyyy MM')
--order by category,FORMAT(order_date,'yyyy MM')
)
select * from(
select *,row_number() over (partition by category order by sales desc ) as rn
from cte
)a 
where rn=1

-- which sub category had higest growth by profit in 2023 compare to 2022
with cte as(
select sub_category, year(order_date)  as _year_ ,sum(sale_price)  AS sales 
from snehith.dbo.df_orders
group by sub_category,year(order_date)
--order by year(order_date), month(order_date)
)
,cte2 as(
select sub_category ,sum(case when _year_=2022 then sales else 0 end ) as sales_2022 , sum(case when _year_=2023 then sales else 0 end) as sales_2023
from cte 
group by sub_category
--order by sub_category
) 
select top 1 *,(sales_2023-sales_2022)*100/sales_2022 as percent_increse
from cte2
order by percent_increse desc