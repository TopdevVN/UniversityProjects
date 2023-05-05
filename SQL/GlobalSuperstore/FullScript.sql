CREATE DATABASE GlobalShop
USE GlobalShop

/*
Using SQL to analyze (query) the sales situation
of the store at an overall level.
*/

-- Preprocessing to create a star schema
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
SELECT TOP 50 * FROM Orders

--Fix Postal Code
	UPDATE Orders
	SET [Postal Code] = IIF([Postal Code] is null, ' ', [Postal Code])

	ALTER TABLE Orders
	ALTER COLUMN [Postal Code] nvarchar(255)

--Add LocationID and Set LocationID's values
	ALTER TABLE Orders
	ADD LocationID nvarchar(255) 

	UPDATE Orders
	SET LocationID = Country + [Postal Code] + City + State

	ALTER TABLE Orders
	ALTER COLUMN LocationID nvarchar(255) not null


--Create table Location
	SELECT DISTINCT LocationID, Country, State, City, Region,[Postal Code], Market
	INTO Location
	FROM Orders
		--Add primary key
		ALTER TABLE Location
		ADD primary key (LocationID)

--Create table Customers
	SELECT DISTINCT [Customer ID], [Customer Name], Segment 
	INTO Customers 
	FROM Orders
	--Change data type
	ALTER TABLE Customers
	ALTER COLUMN [Customer ID] nvarchar(255) not null
	--Add primary key
	ALTER TABLE Customers
	ADD primary key ([Customer ID])

--Create table Products
	SELECT DISTINCT [Product ID], [Product Name], [Sub-Category], Category
	INTO Products
	FROM Orders
	--Change data type
	ALTER TABLE Products
	ALTER COLUMN [Product ID] nvarchar(255) not null
	--Add primary key
	ALTER TABLE Products
	ADD primary key ([Product ID])

--Create table Bills
	SELECT [Row ID], [Order ID], [Order Date], [Ship Date], [Ship Mode],
	[Customer ID], [Product ID], Sales, Quantity, Discount, Profit,
	[Shipping Cost],[Order Priority], LocationID
	INTO Bills FROM Orders

	--Change data type of main column
	ALTER TABLE Bills
	ALTER COLUMN [Row ID] int not null
	--Add primary key
	ALTER TABLE Bills
	ADD primary key ([Row ID])


--Add foreign key
	ALTER TABLE Bills
	ADD constraint FK_Customers foreign key ([Customer ID]) references Customers ([Customer ID]),
	constraint FK_Products foreign key ([Product ID]) references Products ([Product ID]),
	constraint FK_Location foreign key (LocationID) references Location (LocationID)
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------


--Queries--
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--Q1. Doanh thu hàng tháng qua các năm.
--    Monthly revenue over the years.
	SELECT MONTH([Ship Date]) as Months,
	       YEAR([Ship Date]) as Years,
		   Sales, Profit 
	INTO Revenue FROM Bills
	SELECT * FROM Revenue
-- Calculate revenue
	SELECT Months , 
	round(SUM(CASE WHEN Years = 2014 THEN Sales END),2) as [Sum_sale 2014],
	round(SUM(CASE WHEN Years = 2015 THEN Sales END),2) as [Sum_sale 2015],
	round(SUM(CASE WHEN Years = 2016 THEN Sales END),2) as [Sum_sale 2016],
	round(SUM(CASE WHEN Years = 2017 THEN Sales END),2) as [Sum_sale 2017]
	INTO Sum_sales_by_months_in_4_years
	FROM Revenue
	GROUP BY Months
	ORDER BY Months 

SELECT * FROM Sum_sales_by_months_in_4_years ORDER BY Months

--Q2. Lợi nhuận trung bình trên một đơn hàng từng tháng qua các năm.
--    Average profit per order month by month over the years.

SELECT Months , 
		round(SUM(CASE WHEN Years = 2014 THEN Profit END)/count(CASE WHEN Years = 2014 THEN 1 END),0) 
		as [Profit_each_bill_2014],
		round(SUM(CASE WHEN Years = 2015 THEN Profit END)/count(CASE WHEN Years = 2015 THEN 1 END),0) 
		as [Profit_each_bill_2015],
		round(SUM(CASE WHEN Years = 2016 THEN Profit END)/count(CASE WHEN Years = 2016 THEN 1 END),0) 
		as [Profit_each_bill_2016],
		round(SUM(CASE WHEN Years = 2017 THEN Profit END)/count(CASE WHEN Years = 2017 THEN 1 END),0) 
		as [Profit_each_bill_2017]
	INTO Profit_by_months_of_4_years
	FROM Revenue
	GROUP BY Months
	ORDER BY Months 

ALTER TABLE Profit_by_months_of_4_years
ALTER COLUMN Months nvarchar(2)

SELECT * FROM Profit_by_months_of_4_years

SELECT * INTO Average_profit_by_years
FROM Profit_by_months_of_4_years
UNION
SELECT 'Average',
		round(AVG(Profit_each_bill_2014),0),
		round(AVG(Profit_each_bill_2015),0),
		round(AVG(Profit_each_bill_2016),0),
		round(AVG(Profit_each_bill_2017),0)
FROM Profit_by_months_of_4_years
ORDER BY Months

SELECT * FROM Average_profit_by_years 


--Q3. Sản phẩm có lợi nhuận âm năm 2016.
--    Products with negative profits in 2016.
SELECT DISTINCT [Product Name], sum(profit) as Profit_sum into [Product negative profit 1000]
FROM Bills inner join Products on Bills.[Product ID] = Products.[Product ID]
	WHERE Year([Order Date]) = 2016
	GROUP BY [Product Name]
	HAVING sum(Profit) < -1000
	ORDER BY Sum(profit)

SELECT * FROM [Product negative profit 1000] ORDER BY Profit_sum DESC

--Q4. Top 5 quốc gia có lợi nhuận từ điện thoại cao nhất Đông Nam Á năm 2017.
--    Top 5 countries with the highest profit from phones in Southeast Asia in 2017.
SELECT DISTINCT Country, Sum(Profit) as Sum_Profit into Top_5_nations_highest_profit_of_Phones
FROM ((Bills
	INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID])
	INNER JOIN Location ON Bills.LocationID = Location.LocationID) 
		WHERE Region = 'Southeastern Asia' and [Sub-Category] = 'Phones' and Year([Order Date]) = 2017
		GROUP BY Country
		HAVING Sum(Profit) > 0
		ORDER BY Sum(Profit) DESC
-- Thuc te chi co 7 quoc gia
SELECT TOP 5.* 
FROM Top_5_nations_highest_profit_of_Phones 
ORDER BY Sum_Profit DESC


--Q5. Số lượng đơn đặt hàng, tổng số lượng, lợi nhuận, doanh số bán hàng, doanh thu trung bình 
-- theo nhóm hàng trong Quý 4 năm 2017 tại Việt Nam.
-- Number of orders, total quantity, profit, sales, and average revenue by Sub-Category 
-- in Q4 2017 in Vietnam.
	SELECT [Sub-Category],  Count(*) as Number_of_Order,
		Sum(Quantity) as Sum_Quantity, 
		Sum(Profit) as Sum_Profit,
		Sum(Sales) as Sum_Sales, 
		AVG(Sales) as AVG_Sales
	FROM ((Bills
		INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID])
		INNER JOIN Location ON Bills.LocationID = Location.LocationID) 
		WHERE Country = 'Vietnam' 
			and month([Order Date]) between 10 and 12
			and  Year([Order Date]) = 2017
	GROUP BY [Sub-Category]

--Q6. Sản phẩm có lợi nhuận > 1000 vào năm 2014 tại thị trường Châu Á Thái Bình Dương.
--	  Products with profit > 1000 in 2014 in the Asia-Pacific market.
	SELECT [Product Name], Sum(Profit) as Sum_Profit INTO Products_over_1000_profit_in_Asia_Pacific
	FROM ((Bills
		INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID])
		INNER JOIN Location ON Bills.LocationID = Location.LocationID) 
	WHERE Market = 'Asia Pacific' and Year([Order Date]) = 2014 
	GROUP BY [Product Name]
	HAVING Sum(Profit) > 1000

	SELECT * FROM Products_over_1000_profit_in_Asia_Pacific ORDER BY Sum_Profit DESC

--Q7. Số lượng đơn hàng theo từng chế độ ship hàng.
--    Number of orders according to each shipping mode.
	SELECT Category, [Ship Mode], count(*) as Amount INTO [Amount bills by ship mode]
	FROM Bills FULL outer join Products
	ON Bills.[Product ID] = Products.[Product ID]
		GROUP BY Category, [Ship Mode]
		ORDER BY Category 
	SELECT * FROM [Amount bills by ship mode]
--Q8. Top 10 nước có số đơn hàng nhiều nhất.
--    Top 10 countries with the highest number of orders.
	SELECT TOP 10 Country, count(*) as Amount
	FROM (Bills INNER JOIN Location ON Bills.LocationID = Location.LocationID)
	GROUP BY Country
	ORDER BY count(*) DESC

--Q9. Số lượng sản phẩm từng loại mặt hàng dựa trên phân khúc khách hàng.
--    Number of products for each type of Category based on customer segments.
	SELECT Segment,Category,sum(Quantity) as Amount FROM ((Bills
		INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID])
		INNER JOIN Customers ON Bills.[Customer ID] = Customers.[Customer ID])
		GROUP BY Segment,Category
		ORDER BY Segment
--Q10. Số lượng đơn bán ra mỗi năm theo phân khúc khách hàng.
--     Number of orders sold per year by customer segment.
	SELECT Segment,
		COUNT(CASE WHEN year([Ship Date])='2014' THEN 1 END) as Amount_2014,
		COUNT(CASE WHEN year([Ship Date])='2015' THEN 1 END) as Amount_2015,
		COUNT(CASE WHEN year([Ship Date])='2016' THEN 1 END) as Amount_2016,
		COUNT(CASE WHEN year([Ship Date])='2017' THEN 1 END) as Amount_2017
		INTO Amount_bills_by_segment
		FROM (Bills INNER JOIN Customers ON Bills.[Customer ID] = Customers.[Customer ID])
		GROUP BY Segment
		ORDER BY Segment
	SELECT * FROM Amount_bills_by_segment
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
	
