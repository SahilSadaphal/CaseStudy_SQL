/* zomato-schema - users
`zomato-schema - orders`
`zomato-schema - order_details`
 `zomato-schema - restaurants`
 `zomato-schema - menu`
 `zomato-schema - food`
 
 */
 use sql_zomato_cs;

-- Find no. of orders by each customer
SELECT t1.name,count(*) as 'Number Of Orders' from `zomato-schema - users` t1 join `zomato-schema - orders` t2 
on t1.user_id=t2.user_id
group by t1.user_id
order by count(*)


-- Find Restaurants with most no. of Menu items
Select t1.r_id,t1.r_name,count(*) as 'Total Items' from  `zomato-schema - restaurants` t1 
join  `zomato-schema - menu` t2
on t1.r_id=t2.r_id 
group by r_id


-- Find no. of votes and avg rating for all the restaurants
Select t2.r_name,sum(t1.delivery_rating) as 'Total_Votes',avg(t1.delivery_rating) as 'Avg_Rating' from `zomato-schema - orders` t1 
join `zomato-schema - restaurants` t2 
on t1.r_id=t2.r_id
group by t1.r_id
order by Total_Votes;


-- Find the food that is being sold at most no. of Restaurants
Select t2.f_name,count(*) from  `zomato-schema - menu` t1
join `zomato-schema - food` t2 
on t1.f_id=t2.f_id 
group by t1.f_id
order by count(*) desc limit 1;


-- find the restaurants with max revenue in a given month-->May
Select t2.r_name,sum(t1.amount) as 'total_revenue' from `zomato-schema - orders` t1
join  `zomato-schema - restaurants` t2 
on t1.r_id=t2.r_id
where monthname(date(t1.date))='may' 
group by t1.r_id
order by total_revenue desc limit 1;


-- Find the Restaurants revenue > x
Select t2.r_name,sum(t1.amount) as 'Total_Revenue' from `zomato-schema - orders` t1
join `zomato-schema - restaurants` t2
on t1.r_id=t2.r_id
group by t1.r_id
having Total_Revenue>1000;


-- Find the customer who never ordered
Select user_id,name from `zomato-schema - users`
except
select t1.user_id,name from `zomato-schema - orders` t1
join `zomato-schema - users` t2
on t1.user_id=t2.user_id;


-- Show order details of given customer in particular date range
Select t1.user_id,t4.name,t3.f_name,t1.date from `zomato-schema - orders` t1
join `zomato-schema - order_details` t2
on t1.order_id=t2.order_id
join  `zomato-schema - food` t3
on t2.f_id=t3.f_id
join `zomato-schema - users` t4
on t1.user_id=t4.user_id
where t1.user_id=1 and date between '2022-05-15' and '2022-06-15' ;


-- Customer Favourite food
WITH CTE AS (
    SELECT t1.user_id, t3.f_id, COUNT(*) AS total_orders,
           FIRST_VALUE(COUNT(*)) OVER (PARTITION BY t1.user_id ORDER BY COUNT(*) DESC) AS first_value_count,t4.f_name,t1.name
    FROM `zomato-schema - users` t1
    JOIN `zomato-schema - orders` t2 ON t1.user_id = t2.user_id
    JOIN `zomato-schema - order_details` t3 ON t2.order_id = t3.order_id
    JOIN  `zomato-schema - food` t4 on t3.f_id=t4.f_id
    GROUP BY t1.user_id, t3.f_id
)

SELECT name,f_name
FROM CTE
WHERE total_orders = first_value_count;



--  Find most costly restaurants(avg price/dish)
select t1.r_id,sum(price)/count(*) as avg_price,t2.r_name from `zomato-schema - menu` t1 
join `zomato-schema - restaurants` t2
on t1.r_id=t2.r_id
group by r_id
order by avg_price desc limit 1;

-- find delivery boy compensation using the formula (no.deliveries*100+1000*avg_rating)
select t1.partner_name,count(*)*100+1000*avg(t2.delivery_rating) as compensation from `zomato-schema - delivery_partner` t1
join `zomato-schema - orders` t2 on t1.partner_id=t2.partner_id
group by t1.partner_id;


-- Find all the restaurants that are veg
select *,t3.r_name from`zomato-schema - food` t1
join `zomato-schema - menu` t2 
on t1.f_id=t2.f_id
join `zomato-schema - restaurants` t3
on t2.r_id=t3.r_id
group by t2.r_id
having min(t1.type)='veg' and max(t1.type)='veg';


-- Find min and max value of each customer
select t1.name,min(t2.amount) as 'min',max(t2.amount) as 'max' from `zomato-schema - users` t1
join `zomato-schema - orders` t2
on t1.user_id=t2.user_id
group by t1.user_id