create database zomato;
use zomato;
select * from zomato;
/* 1) Help Zomato in identifying the cities with poor Restaurant ratings */
select round(Avg(Rating),0) into @Avg_Rating
from zomato;
select @Avg_Rating;
select city, round(avg(rating)) as city_wise_rating
from zomato
group by city
having city_wise_rating < @Avg_Rating;

/* 2) Mr.roy is looking for a restaurant in kolkata which provides online delivery. Help him choose the best restaurant */
select RestaurantID, city, cuisines, rating
from zomato
where city = 'Kolkata'
group by RestaurantID, city,cuisines,rating
order by rating desc
Limit 1;

/* 3) Help Peter in finding the best rated Restraunt for Pizza in New Delhi. */
select RestaurantID, city, cuisines, rating
from zomato
where city = 'New Delhi' and cuisines like '%pizza%'
group by RestaurantID, city, cuisines, rating
order by rating desc
Limit 1;

/* 4)Enlist most affordable and highly rated restaurants city wise. */

with cte as (select RestaurantID, City, cuisines, Average_Cost_for_two, Rating,
rank() over (partition by City order by Average_Cost_for_two,Rating desc) as Rn
from zomato
where Average_Cost_for_two > 0)
select RestaurantID, City, cuisines, Average_Cost_for_two, Rating
from cte
where Rn = 1;

/* 5)Help Zomato in identifying the restaurants with poor offline services */

select city, cuisines, rating
from zomato
where has_table_booking = 'Yes'
order by 3;

/* 6)Help zomato in identifying those cities which have atleast 3 restaurants with ratings >= 4.9. In case there are two cities with the same 
result, sort them in alphabetical order. */
  
  select city, cuisines, rating, count(*) as cnt
  from zomato
  group by city, cuisines, rating
  having rating >= 4.9 and cnt >= 3;
  
  /* 7) What are the top 5 countries with most restaurants linked with Zomato? */
  
  with cte as (select a.*, b.country
  from zomato as a
  inner join
  countrytable as b
  on a.countrycode = b.countrycode)
  select country, round(avg(rating),2) as cte2
  from cte
  group by country
  order by cte2 desc
  limit 5;
  
  /* 8) What is the average cost for two across all Zomato listed restaurants? */
  
  select cuisines, average_cost_for_two
  from zomato
  group by 1,2;
  
  /* 9) Group the restaurants basis the average cost for two into: Luxurious Expensive, Very Expensive, Expensive, High, Medium High, Average. 
Then, find the number of restaurants in each category. */

WITH cost_groups AS (
    SELECT 
        average_cost_for_two,
        NTILE(6) OVER (ORDER BY average_cost_for_two) AS Grps
    FROM (
        SELECT DISTINCT average_cost_for_two
        FROM zomato
        WHERE average_cost_for_two > 10
    ) d
), cg_2 as
(SELECT 
    a.RestaurantID,
    b.country,
    cg.Grps,
    a.average_cost_for_two
FROM zomato a
JOIN countrytable b
    ON a.countrycode = b.countrycode
JOIN cost_groups cg
    ON a.average_cost_for_two = cg.average_cost_for_two
WHERE a.average_cost_for_two > 10
order by Grps)
select Grps, count(*) as count
from cg_2
group by Grps
order by Grps;


/* 10) List the two top 5 restaurants with highest rating with maximum votes. */

with cte as(select Restaurantid, cuisines, rating, votes as max_votes
from zomato
group by 1, cuisines, rating, max_votes
order by rating desc, max_votes desc),
cte2 as (select *, rank() over (partition by rating order by max_votes desc) as rn
from cte
order by rating desc)
select * from cte2
where rn=1
limit 5;


  
  


