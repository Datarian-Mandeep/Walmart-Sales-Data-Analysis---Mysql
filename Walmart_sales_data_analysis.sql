use Walmart
select * from SalesData

----------------Feature Engineering----------------------------------------------------------------------------------------

 --Time of the day

alter table salesdata
add time_of_day varchar(20)

select SalesData.Time,
	(CASE
		when SalesData.Time Between '00:00:00' And '12:00:00' Then 'Morning'
		when SalesData.Time Between '12:01:00' And '16:00:00' Then 'Afternoon'
		Else 'Evening'
	END
	) as time_of_day
from SalesData;

update SalesData
set SalesData.time_of_day = (
	CASE
		when SalesData.Time Between '00:00:00' And '12:00:00' Then 'Morning'
		when SalesData.Time Between '12:01:00' And '16:00:00' Then 'Afternoon'
		Else 'Evening'
	END
	)

-- Day Name

alter table salesdata
add Day_name varchar(10)

update SalesData
set Day_name = FORMAT(cast(Date as DATE),'dddd')

-- Month Name

alter table salesdata
add Month_Name varchar(10)

update salesdata
set Month_Name = DATENAME(month,Date) 

---------------------------------------Exploratory Data Analysis-------------------------------------------------
--------------Generic Question----

-- How many unique cities does the data have?
select distinct(city)
from salesdata

-- how many unique branch does the data have
select distinct(branch)
from salesdata

-- in which city is each branch
select distinct city, branch
from salesdata
order by branch

-------------------------------------------------PRODUCTS-------------------------------------------------------------------

--1. How many unique product lines does the data have?
select distinct([product line])
from salesdata

--2. What is the most common payment method?
select payment, count(*) as Payment_times
from salesdata
group by payment
order by Payment_times desc

--3. What is the most selling product line?
select [Product line], count([Product line]) as times_sold
from salesdata
group by [product line]
order by times_sold desc

--4. What is the total revenue by month?
select Month_Name, sum(cast(Total as Decimal(10,2))) as Total_revenue
from salesdata
group by Month_Name
order by Total_revenue desc

--5. What month had the largest COGS?
select month_name, sum(cast(cogs as Decimal(10,2))) as total_cogs
from salesdata
group by month_name
order by total_cogs desc

--6. What product line had the largest revenue?
select [product line], sum(cast([total] as decimal(10,5))) as total_revenue
from salesdata
group by [product line]
order by total_revenue desc

--7. What is the city with the largest revenue?
select city, sum(cast(total as decimal(10,2))) as total_revenue
from salesdata
group by [city]
order by total_revenue desc

--8.What product line had the largest VAT?
select [product line], Avg(cast([Tax 5%] as float)) as Avg_VAT
from salesdata
group by [Product line]
order by Avg_VAT desc

--9.Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

select avg(cast(Total as Decimal(10,5))) from salesdata

select [product line], avg(cast(total as decimal(10,2))) as avg_sales
from salesdata
group by [product line]

select [product line],
	(CASE
		when avg(cast(total as decimal(10,2))) > (select avg(cast(total as Decimal(10,2))) from salesdata) then 'Good'
		when avg(cast(total as decimal(10,2))) < (select avg(cast(total as Decimal(10,2))) from salesdata) then 'Bad'
	 END	
	 ) as Performance
from salesdata
group by [product line]
order by Performance desc

--10. Which branch sold more products than average product sold?

select branch
from salesdata
group by branch
having avg(cast(quantity as int)) >=
					(select avg(cast(quantity as int)) from salesdata)

-- 11. Average items sold in each branch
select branch, avg(cast(quantity as int)) as avg_sold
from salesdata
group by branch

--12. What is the most common product line by gender?
select Gender,[product line],sum(cast(quantity as int)) as total_sold
from salesdata
group by Gender,[product line]
having Gender = 'Male'
order by total_sold desc

-- 13. What is the average rating of each product line?
select [product line], ROUND(avg(cast(rating as decimal(3,1))),2) as Avg_rating
from salesdata
group by [product line]
order by avg_rating desc

-----------------------------------------SALES-----------------------------------------------------------------------------------

use walmart

--1. Number of sales made in each time of the day per weekday
select distinct(Day_name) , time_of_day, count(time_of_day) as sales_counts
from salesdata
where  Day_name IN ( 'sunday','Saturday')
group by Day_name, time_of_day
order by day_name 

--During weekdays mostly customers come in the evening 

--2. Which of the customer types brings the most revenue?
select [customer type], round(sum(cast(total as decimal(10))),0) as total_revenue
from salesdata
group by [customer type]
order by total_revenue desc

-- Member customers are contributing more into the revenue

--3. Which city has the largest tax percent/ VAT (**Value Added Tax**)?
select city,branch,sum(cast([Tax 5%] as Decimal(10))) as total_VAT
from salesdata
group by city,branch
order by total_VAT desc

-- city Naypyitaw branch C collecting more VAT 

--4. Which customer type pays the most in VAT?
select [Customer type], sum(cast([Tax 5%] as Decimal(10))) as Total_VAT
from salesdata
group by [Customer type]
order by Total_VAT desc

-- Member of walmart contributing more in VAT then Normal Customers

select * from salesdata

