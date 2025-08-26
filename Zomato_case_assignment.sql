create database zomato;
use zomato;
/* 1) Help Zomato in identifying the cities with poor Restaurant ratings */
select round(Avg(Rating),0) into @Avg_Rating
from zomato;
select @Avg_Rating;
select city, round(avg(rating)) as city_wise_rating
from zomato
group by city
having city_wise_rating < @Avg_Rating;

/* 2) Mr.roy is looking for a restaurant in kolkata which provides online 
delivery. Help him choose the best restaurant */
select city, cuisines, rating
from zomato
where city = 'Kolkata'
group by city,cuisines,rating
order by rating desc
Limit 1;

/* 3) Help Peter in finding the best rated Restraunt for Pizza in New Delhi. */
select city, cuisines, rating
from zomato
where city = 'New Delhi' and cuisines like '%pizza%'
group by city,cuisines,rating
order by rating desc
Limit 1;

/* 4)Enlist most affordable and highly rated restaurants city wise. */

with cte as (select city, cuisines, average_cost_for_two, rating, rank() over (partition by average_cost_for_two order by average_cost_for_two, rating desc)
as Rn
from zomato
where average_cost_for_two >0)
select city, cuisines, average_cost_for_two, rating from cte
where rn=1;

/* 5)Help Zomato in identifying the restaurants with poor offline services */

select city, cuisines, rating
from zomato
where has_table_booking = 'Yes'
order by 3;

/* 6)Help zomato in identifying those cities which have atleast 3 restaurants with ratings >= 4.9
  In case there are two cities with the same result, sort them in alphabetical order. */
  
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
  
  /* 9) Group the restaurants basis the average cost for two into: 
Luxurious Expensive, Very Expensive, Expensive, High, Medium High, Average. 
Then, find the number of restaurants in each category. */

with cte as (select country, ntile(6) over (order by average_cost_for_two) as Grps, average_cost_for_two
from zomato as a
inner join countrytable as b
on a.countrycode = b.countrycode
where average_cost_for_two > 10
order by Grps)
select country, case when grps=1 then "Average"
when grps=2 then "Medium high"
when grps=3 then "High"
when grps=4 then "Expensive"
when grps=5 then "Very Expensive"
else "Luxurious Expensive"
end as Grps, avg(average_cost_for_two)
from cte
group by 1,2;

/* 10) List the two top 5 restaurants with highest rating with maximum votes. */

with cte as(select cuisines, rating, votes as max_votes
from zomato
group by cuisines, rating, max_votes
order by rating desc, max_votes desc),
cte2 as (select *, rank() over (partition by rating order by max_votes desc) as rn
from cte
order by rating desc)
select * from cte2
where rn=1
limit 5;


  
  


