
--------------------------create database Electronics----------------

create database Electronics_DB

use Electronics_DB

---------------------------------------------------------------------

select * from customers1

select * from products1

select * from stores1

select * from Exchange_Rates1

select * from Sales1

alter table Sales1
add Revenue decimal(18, 2);


update Sales1
set Revenue = sa.Quantity * p.Unit_Price_USD
from Sales1 as sa INNER JOIN products1 as p 
on sa.ProductKey = p.ProductKey;


--------------------------------------------------------------------------------------

----------------------------1. Which products generate the highest revenue? Is there a correlation with specific brands or categories?-------------------

select * from Sales1
select * from products1


select p.Product_Name , p.Brand , p.Category , sum (p.Unit_Price_USD * s.Quantity) as 'Revenue' 
from products1 as p inner join Sales1 as s
on p.ProductKey = s.ProductKey
group by Product_Name ,  p.Brand , p.Category
order by sum (p.Unit_Price_USD * s.Quantity) desc

----------------------------------------------------------------------------------------------------------------------------------

 ----------------------------------2. How does sales performance vary across different stores, states, or countries?

select * from Sales1
select * from stores1

select s.Storekey, s.Country, s.State, sum (sa.Quantity) as 'Total quantity'
from stores1 as s inner join Sales1 as sa
on s.Storekey = sa.Storekey
group by s.Storekey, s.Country, s.State
order by sum (sa.Quantity) asc

-----------------------------------------------------------------------------------------------------------

-----------------------------3. What is the average order size (in quantity and revenue) across regions or stores?-----------------

select * from Sales1
select * from stores1
select * from products1

select avg (sa.Quantity) as 'Average quantity', avg(sa.Revenue) as 'Average revenue', st.Country, st.State, st.Square_Meters From
Sales1 as sa inner join stores1 as st
on sa.StoreKey = st.StoreKey
group by st.Country, st.State, st.Square_Meters

              ------------------------------------------------------------------------------------
select avg (SAD.Quantity) as 'Average quantity',
       avg(PD.Revenue) as 'Average revenue',
	   STD.Country,
	   STD.State,
	   STD.Square_Meters
From 
   (select (p.Unit_Price_USD * sa.Quantity) as 'Revenue', sa.ProductKey from products1 as p inner join Sales1 as sa
   on sa.ProductKey = p.ProductKey) AS PD
INNER JOIN 
   (select st.Country , st.State, st.Square_Meters, sa.StoreKey from stores1 as st inner join Sales1 as sa
   on sa.StoreKey = st.StoreKey) AS STD 
ON PD.ProductKey = STD.StoreKey
INNER JOIN 
   (select avg(Quantity) as 'quantity', ProductKey  from Sales1
   group by ProductKey) as SAD
ON STD.StoreKey = SAD.ProductKey                                                                 
GROUP BY STD.Country,
	     STD.State,
	     STD.Square_Meters

		                                                                           ON PD.ProductKey = SAD.ProductKey 
              ------------------------------------------------------------------------------
SELECT 
    st.storekey, 
    AVG(sa.quantity) AS avg_quantity, 
    AVG(sa.quantity * p.Unit_Price_USD) AS avg_revenue
FROM 
    Sales1 sa
JOIN 
    stores1 st
ON 
    sa.storekey = st.storekey
JOIN 
    products1 p
ON 
    sa.productkey = p.productkey
GROUP BY 
    st.storekey

---------------------------------------------------------------------------------------------------------------

----------------4. Are there any seasonal trends in sales based on the Order Date and Delivery Date?--------------

select * from Sales1
select * from products1

select p.Product_Name, format (s.Order_Date, 'yyyy') as 'Order_Date', format (s.Delivery_Date, 'yyyy') as ' Delivery_Date'from products1 as p
inner join Sales1 as s
on p.ProductKey = s.ProductKey
----------------------------------------------------------------------------------------------------------------------

--------5.What is the gender distribution of customers, and how does it vary across regions?---------

select * from customers1


select Gender, Name, City, State, Country from customers1

--------------------------------------------------------------------------------------------------------------

---------------6.Which age group (derived from the Birthday field) contributes the most to sales revenue?----------

select * from customers1
select * from Sales1
select * from products1



alter table customers1
add Age int


update customers1 
set Age = year(getdate())-year(Birthday)



Select CU.Age_group ,sum (SA.Revenue) as 'Total revenue' 
FROM
    (select CustomerKey,
	     case
		    when Age >= 23 and Age <= 29 then '23-29'
			when Age >= 30 and Age <= 39 then '30-39'
			when Age >= 40 and Age <= 49 then '40-49'
			when Age >= 50 and Age <= 59 then '50-59'
			when Age >= 60 and Age <= 69 then '60-69'
			when Age >= 70 and Age <= 79 then '70-79'
			when Age >= 80 and Age <= 90 then '80-90'
			else '90+'
      end Age_group
	  from customers1) as CU
INNER JOIN 
    Sales1 as SA 
ON CU.CustomerKey = SA.CustomerKey
GROUP BY CU.Age_group



	   
------------------------------------------------------------------------------------------------------------------------

------------------7.What is the geographical distribution of customers (city, state, country, or continent) for the top 10 products or categories?

select * from Sales1
select * from customers1
select * from products1

select top 10 Product_Name, Category, Subcategory, City, State, Country from products1, customers1

         ----------------------------------------------------------------
select top 10 PD.Product_Name, PD.Category, PD.Subcategory, CD.City, CD.State, CD.Country 
FROM 
   (select p.Product_Name, p.Category, p.Subcategory,sa.ProductKey from products1 as p inner join Sales1 as sa 
   on p.ProductKey = sa.ProductKey) as PD

INNER JOIN
   (select c.City, c.State, c.Country, sa.CustomerKey from customers1 as c inner join Sales1 as sa
   on c.CustomerKey = sa.CustomerKey) as CD
on PD.ProductKey = CD.CustomerKey

--------------------------------------------------------------------------------------------

-------8.Are there any noticeable trends in purchasing behavior by continent or country?


select * from Sales1
select * from customers1
select * from products1


select c.CustomerKey, c.City , c.Country , sum (sa.Revenue) as 'Total revenue' from customers1 as c
inner join Sales1 as sa
on c.CustomerKey = sa.CustomerKey
group by c.CustomerKey, c.City , c.Country 
order by c.CustomerKey, c.City , c.Country, sum(sa.Revenue) asc

-----------------------------------------------------------------------------------------------------------------------------------

-----------------------9- Which product categories or subcategories have the highest and lowest sales?-------------------------

select * from Sales1
select * from products1

select p.ProductKey, p.Category, p.Subcategory, sum(sa.Revenue) as 'Total revenue' from products1 as p
inner join Sales1 as sa
on p.ProductKey = sa.ProductKey
group by p.ProductKey, p.Category, p.Subcategory
order by p.ProductKey, p.Category, p.Subcategory, sum(sa.Revenue) asc

---------------------------------------------------------------------------------------------------------

--------------10-How does the profit margin (difference between Unit Price USD and Unit Cost USD) vary by category or brand?-------------------------------

select * from Sales1
select * from products1


select Brand, Category,(Unit_Price_USD - Unit_Cost_Usd) as Profit from products1

------------------------------------------------------------------------------------------------------------------------
-----------------11-Are certain product colors or brands more popular in specific regions or among specific customer groups?----------

select * from products1
select * from customers1


select Color, Brand, Gender,count(Gender)as 'Tatal gender' from products1 ,customers1
group by  Color, Brand, Gender
order by Color, Brand, Gender,count(Gender) asc

---------------------------------------------------------------------------------------------------------------------------------

-------------------12-Which stores are the most and least profitable based on sales revenue?---------------------

select * from Sales1
select * from stores1

select st.StoreKey, st.Country, st.State , sum(sa.Revenue) as 'Total revenue' from stores1 as st
inner join Sales1 as sa 
on st.StoreKey = sa.StoreKey
group by st.StoreKey, st.Country, st.State 
order by st.StoreKey, st.Country, st.State , sum(sa.Revenue) asc

----------------------------------------------------------------------------------------------------------------------

--------------•13- Does the store size (Square Meters) correlate with its sales performance or revenue?

select * from Sales1
select * from stores1


select st.Square_Meters, sum(sa.Revenue) as 'Total revenue' from stores1 as st
inner join Sales1 as sa 
on st.StoreKey = sa.StoreKey
group by st.Square_Meters
order by st.Square_Meters, sum(sa.Revenue) asc

-------------------------------------------------------------------------------------------------------

---------------------•14- How do sales trends differ between older and newer stores (based on Open Date)?

select * from Sales1
select * from stores1



select st.Open_Date , sum(sa.Revenue) as 'Total revenue' from stores1 as st
inner join Sales1 as sa
on st.StoreKey = sa.StoreKey
group by st.Open_Date
order by st.Open_Date , sum(sa.Revenue) asc

----------------------------------------------------------------------------------------------

---------------------•15- What is the average delivery time across regions, and which regions or stores have the fastest delivery?---

select * from stores1
select * from Sales1


select datediff(day, sa.Order_Date, sa.Delivery_Date) as 'Delivery time' , st.Country, st.State from Sales1 as sa
inner join stores1 as st
on sa.StoreKey = st.StoreKey
group by datediff(day, sa.Order_Date, sa.Delivery_Date), st.Country, st.State
order by datediff(day, sa.Order_Date, sa.Delivery_Date), st.Country, st.State asc

----------------------------------------------------------------------------------------------------------------------------------

----------•16- Are there any patterns in delayed deliveries (difference between Order Date and Delivery Date) for specific products or stores?

select * from stores1
select * from Sales1
select * from products1

select datediff(day, Order_Date, Delivery_Date) as 'Delivery time', Product_Name, Country from 
Sales1, products1, stores1
------------------------------------------------------------------------------------------------

-----------•17- How does order size impact delivery times?---------

select Quantity, datediff(day, Order_Date, Delivery_Date) as 'Delivery time' from Sales1
order by Quantity, datediff(day, Order_Date, Delivery_Date) asc

----------------------------------------------------------------------------------------------------------

----------------•18 How do fluctuations in exchange rates affect sales revenue in non-USD currencies?

select * from Sales1
select * from Exchange_Rates1


select ex.Currency, ex.Exchange, sum(sa.Revenue)as 'Total revenue' from Exchange_Rates1 as ex
inner join Sales1 as sa
on ex.Currency = sa.Currency_Code
where ex.Currency<> 'USD'
group by ex.Currency, ex.Exchange 

-----------------------------------------------------------------------------

---19-• Are there any noticeable patterns in order frequency or volume when exchange rates are favorable for specific currencies?

select * from Sales1
select * from Exchange_Rates1
select * from products1


select ex.Currency, ex.Exchange, sa.Quantity from Exchange_Rates1 as ex
inner join Sales1 as sa
on ex.Currency = sa.Currency_Code

--------------------------------------------------------------------------------------

--------•20- Which currencies contribute the most to revenue? How does this align with store locations and customer regions?

select * from Sales1
select * from Exchange_Rates1
select * from stores1


select sa.Currency_Code , sum(sa.Revenue) as 'Total revenue' , st.Country, st.State From Sales1 as sa 
Inner join stores1 as st
ON st.StoreKey = sa.StoreKey
group by sa.Currency_Code, st.Country, st.State
order by sa.Currency_Code , sum(sa.Revenue) , st.Country, st.State

----------------------------------------------------------------------------------------------------------------

-------------21• How does revenue vary for customers ordering in different currencies?

select * from Sales1
select * from Exchange_Rates1


select sa.Quantity , sa.Currency_Code, sum(sa.Revenue)as 'Total revenue', ex.Exchange from Sales1 as sa
inner join Exchange_Rates1 as ex
on sa.Currency_Code = ex.Currency
group by sa.Quantity , sa.Currency_Code, ex.Exchange

------------------------------------------------------------------------------------------------------------------------------

-----22• What is the relationship between customer demographics (age, gender, location) and product categories purchased?


select * from products1
select * from customers1


select (year(getdate())-year(Birthday)) as 'Age', Gender, City, Country , Category from customers1 , products1

-----------------------------------------------------------------------------------------------------------

---------------------23• How does sales revenue per customer vary by region, store size, and currency?

select * from stores1
select * from Sales1
select * from Exchange_Rates1
select * from customers1
select * from products1


select CD.Name, STD.State, STD.Square_Meters,EXD.Exchange, PD.Revenue from 

   (select sa.CustomerKey, c. Name  from Sales1 as sa inner join customers1 as c 
   on sa.CustomerKey = c.CustomerKey) as CD

INNER JOIN 
   (select sa.StoreKey , st.Country , st.State , st.Square_Meters from Sales1 as sa inner join stores1 as st
   on sa.StoreKey = st.StoreKey) as STD
ON CD.CustomerKey = STD.StoreKey

INNER JOIN
   (select sa.Currency_Code, ex.Exchange from Sales1 as sa inner join Exchange_Rates1 as ex 
   on sa.Currency_Code = ex.Currency) as EXD 
ON STD.StoreKey = EXD.Currency_Code

INNER JOIN 
   (select sa.ProductKey, (sa.Quantity * p.Unit_Price_USD) as 'Revenue' from Sales1 as sa inner join products1 as p
   on sa.ProductKey = p.ProductKey ) as PD
ON EXD.Currency_Code = PD.ProductKey



                    -------------------------------------------------------------------------

SELECT 
    CD.CustomerKey, 
    STD.StoreKey, 
    EXD.Currency_Code, 
    PD.Revenue
FROM 
    (SELECT 
        sa.CustomerKey, 
        c.Name 
     FROM 
        Sales1 AS sa 
     INNER JOIN 
        customers1 AS c ON sa.CustomerKey = c.CustomerKey) AS CD

INNER JOIN 
    (SELECT 
        sa.StoreKey, 
        st.Country, 
        st.State, 
        st.Square_Meters 
     FROM 
        Sales1 AS sa 
     INNER JOIN 
        stores1 AS st ON sa.StoreKey = st.StoreKey) AS STD 
     ON CD.CustomerKey = STD.StoreKey

INNER JOIN
    (SELECT 
        sa.Currency_Code, 
        ex.Exchange 
     FROM 
        Sales1 AS sa 
     INNER JOIN 
        Exchange_Rates1 AS ex ON sa.Currency_Code = ex.Currency) AS EXD 
     ON STD.StoreKey = EXD.Currency_Code

INNER JOIN 
    (SELECT 
        sa.ProductKey, 
        (sa.Quantity * p.Unit_Price_USD) AS Revenue 
     FROM 
        Sales1 AS sa 
     INNER JOIN 
        products1 AS p ON sa.ProductKey = p.ProductKey) AS PD 
     ON EXD.Currency_Code = PD.ProductKey;

-------------------------------------------------------------------------------------------------------------------------

---24• Are there patterns between product subcategories and the type of stores selling them (e.g., store size, country, or state)

select * from products1
select * from stores1
select * from Sales1

select Subcategory, Country,State, Square_Meters from products1, stores1