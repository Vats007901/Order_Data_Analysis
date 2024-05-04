
/*create table df_orders (
[order_id] int primary key
,[order_date] date
,[ship_mode] varchar (20) , 
[segment] varchar (20)
,[country] varchar (20),
[city] varchar (20) ,
,[state] varchar (20) ,[postal_code] varchar (20) 
,[region] varchar (20) 
,[category] varchar (20) , [sub_category] varchar (20) ,
[product_id] varchar (50) ,[quantity] int
, [discount] decimal (7,2) ,[sale_price] decimal (7,2),[profit] decimal (7,2))) */

select * from df_orders

-- find top 10 highest revenue generating products

select  top 10 product_id, sum(sale_price)as sum_total 
from df_orders
group by product_id
order by sum_total desc


--find top 5 highest selling products in each region

with cte_sum as(
select  product_id, region, sum(sale_price)as sum_total 
from df_orders
group by product_id, region
 )
, cte_rank as(
select *, ROW_NUMBER() over( partition  by region order by sum_total desc)as rank from cte_sum
)
select product_id, region, sum_total from cte_rank where rank<=5 order by region desc, sum_total desc

 
 --find month over month growth comparision for 2022 and 2023 sales ; jan 2022 vs jan 2023
	with cte_montlysales as(
	select year(order_date) as order_year, month(order_date)  as month_year,sum(sale_price) as sales
	from df_orders
	group by year(order_date),month(order_date) 
	)

	select month_year , sum(case when  order_year=2022 then sales else 0  end) as sales_2022 ,
	sum(case when  order_year=2023 then sales else 0 end) as sales_2023   from cte_montlysales group by month_year;

	--for each category which month had highest sales
	with cte_month as (
	select category,format(order_date,'yyyyMM')as order_year_month ,sum(sale_price) as sales from df_orders group by category,format(order_date,'yyyyMM')
  )
  , cte_rank as(
  select category,order_year_month , row_number() over(partition by category order by sales desc) as rnk from cte_month)
  select category, order_year_month from cte_rank where rnk=1;


  --which subcategory has highest growth by profit in 2023 compared to 2022
  with cte_temp as(
  select sub_category, year(order_date)as order_year, month(order_date)as order_month , sum(profit) as profit from df_orders  
  group by sub_category, year(order_date), month(order_date)   
   )
   , cte_temp2 as(
  select sub_category, sum(case when  order_year=2022 then profit else 0 end) as profit_2022,
  sum(case when  order_year=2023 then profit else 0 end) as profit_2023 from cte_temp group by sub_category
  )

 
  select top 1 *, ((profit_2023-profit_2022)/profit_2022) as growth_profit from cte_temp2 order by growth_profit desc 
