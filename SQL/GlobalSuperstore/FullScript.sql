CREATE DATABASE GlobalShop
USE GlobalShop

--Import Dataset from excel file using Import & Export Wizard
SELECT TOP 50 * FROM Orders

--Fix Postal Code
	UPDATE Orders
	SET [Postal Code] = IIF([Postal Code] IS NULL, ' ', [Postal Code])
	
	SELECT top 50 [Postal Code] FROM Orders

	ALTER TABLE Orders
	ALTER COLUMN [Postal Code] NVARCHAR(255)

--ADD LocationID and SET LocationID's values
	ALTER TABLE Orders
	ADD LocationID NVARCHAR(255) 

	update Orders
	SET LocationID = Country + [Postal Code] + City + State

	ALTER TABLE Orders
	ALTER COLUMN LocationID NVARCHAR(255) not null

--##create table Location
	SELECT DISTINCT LocationID, Country, State, City, Region,[Postal Code], Market
	INTO Location
	FROM Orders
		--##ADD PRIMARY KEY
		ALTER TABLE Location
		ADD PRIMARY KEY (LocationID)

--create table Customers
	SELECT DISTINCT [Customer ID], [Customer Name], Segment 
	INTO Customers 
	FROM Orders
	--change data type
	ALTER TABLE Customers
	ALTER COLUMN [Customer ID] NVARCHAR(255) not null
	--ADD PRIMARY KEY
	ALTER TABLE Customers
	ADD PRIMARY KEY ([Customer ID])

--create table Products
	SELECT DISTINCT [Product ID], [Product Name], [Sub-Category], Category
	INTO Products
	FROM Orders
	--change data type
	ALTER TABLE Products
	ALTER COLUMN [Product ID] NVARCHAR(255) not null
	--ADD PRIMARY KEY
	ALTER TABLE Products
	ADD PRIMARY KEY ([Product ID])

--create table Bills
	SELECT [Row ID], [Order ID], [Order Date], [Ship Date], [Ship Mode],
	[Customer ID], [Product ID], Sales, Quantity, Discount, Profit,
	[Shipping Cost],[Order Priority], LocationID
	INTO Bills FROM Orders

	--change data type of main column
	ALTER TABLE Bills
	ALTER COLUMN [Row ID] int not null
	--ADD PRIMARY KEY
	ALTER TABLE Bills
	ADD PRIMARY KEY ([Row ID])


--ADD FOREIGN KEY
	ALTER TABLE Bills
	ADD CONSTRAINT FK_Customers FOREIGN KEY ([Customer ID]) REFERENCES Customers ([Customer ID]),
	CONSTRAINT FK_Products FOREIGN KEY ([Product ID]) REFERENCES Products ([Product ID]),
	CONSTRAINT FK_Location FOREIGN KEY (LocationID) REFERENCES Location (LocationID)


--TRUY VẤN DỮ LIỆU--

--Q1: Tính doanh thu hàng tháng qua từng năm
--SELECT value
	SELECT month([Ship Date]) AS Months,
	       year([Ship Date]) AS Years,
		   Sales, Profit 
	INTO Revenue FROM Bills
	SELECT * FROM Revenue
	ORDER BY Years, Months
--Tính doanh thu từng tháng qua các năm
	SELECT Months , 
	ROUND(SUM(CASE WHEN Years = 2014 THEN Sales END),2) AS [SUM_sale 2014],
	ROUND(SUM(CASE WHEN Years = 2015 THEN Sales END),2) AS [SUM_sale 2015],
	ROUND(SUM(CASE WHEN Years = 2016 THEN Sales END),2) AS [SUM_sale 2016],
	ROUND(SUM(CASE WHEN Years = 2017 THEN Sales END),2) AS [SUM_sale 2017]
	INTO SUM_sales_by_months_in_4_years
	FROM Revenue
	GROUP BY Months
	ORDER BY Months 

SELECT * FROM SUM_sales_by_months_in_4_years ORDER BY Months

--Q2: Lợi nhuận trung bình trên một đơn hàng theo từng tháng mỗi năm

/* Short & eASy version
	SELECT Months, 
			ROUND(AVG(CASE WHEN Years = 2014 THEN Profit END), 0) AS Profit_each_bill_2014, 
			ROUND(AVG(CASE WHEN Years = 2015 THEN Profit END), 0) AS Profit_each_bill_2015, 
			ROUND(AVG(CASE WHEN Years = 2016 THEN Profit END), 0) AS Profit_each_bill_2016, 
			ROUND(AVG(CASE WHEN Years = 2017 THEN Profit END), 0) AS Profit_each_bill_2017 
		INTO AVG_PROFIT_PERORDER_OV4YEARS
		FROM Revenue 
		GROUP BY Months 
		ORDER BY Months;
*/

--SELECT * FROM AVG_PROFIT_PERORDER_OV4YEARS
--ORDER BY Months

/*SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Profit_by_months_of_4_years'*/

SELECT Months , 
		ROUND(SUM(CASE WHEN Years = 2014 THEN Profit END)/count(CASE WHEN Years = 2014 THEN 1 END),0) 
		AS [Profit_each_bill_2014],
		ROUND(SUM(CASE WHEN Years = 2015 THEN Profit END)/count(CASE WHEN Years = 2015 THEN 1 END),0) 
		AS [Profit_each_bill_2015],
		ROUND(SUM(CASE WHEN Years = 2016 THEN Profit END)/count(CASE WHEN Years = 2016 THEN 1 END),0) 
		AS [Profit_each_bill_2016],
		ROUND(SUM(CASE WHEN Years = 2017 THEN Profit END)/count(CASE WHEN Years = 2017 THEN 1 END),0) 
		AS [Profit_each_bill_2017]
	INTO Profit_by_months_of_4_years
	FROM Revenue
	GROUP BY Months
	ORDER BY Months 

ALTER TABLE Profit_by_months_of_4_years
ALTER COLUMN Months char(2)

SELECT * FROM Profit_by_months_of_4_years
ORDER BY Months 

SELECT * INTO Average_profit_by_years
FROM Profit_by_months_of_4_years
union
SELECT 'Average',
		ROUND(AVG(Profit_each_bill_2014),0),
		ROUND(AVG(Profit_each_bill_2015),0),
		ROUND(AVG(Profit_each_bill_2016),0),
		ROUND(AVG(Profit_each_bill_2017),0)
FROM Profit_by_months_of_4_years
ORDER BY Months

SELECT * FROM Average_profit_by_years 


----Q3.Sản phẩm có lợi nhuận âm năm 2016
SELECT DISTINCT [Product Name], SUM(profit) AS Profit_SUM 
INTO [Product negative profit 1000]
FROM Bills inner join Products on Bills.[Product ID] = Products.[Product ID]
	where YEAR([Order Date]) = 2016
	GROUP BY [Product Name]
	having SUM(Profit) < -1000
	ORDER BY SUM(profit)

SELECT * FROM [Product negative profit 1000] ORDER BY Profit_SUM DESC

--Q4.Top 5 quốc gia có lợi nhuận từ điện thoại cao nhất Đông Nam Á năm 2017
SELECT DISTINCT Country, SUM(Profit) AS SUM_Profit 
INTO Top_5_nations_highest_profit_of_Phones
FROM Bills
	 INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID]
	 INNER JOIN Location ON Bills.LocationID = Location.LocationID
		where Region = 'SoutheAStern ASia' and [Sub-Category] = 'Phones' and YEAR([Order Date]) = 2017
		GROUP BY Country
		having SUM(Profit) > 0
		ORDER BY SUM(Profit) DESC
-- Thuc te chi co 7 quoc gia
SELECT TOP 5.* FROM Top_5_nations_highest_profit_of_Phones ORDER BY SUM_Profit DESC


--Q5.Số lượng đơn đặt hàng, tổng số lượng, lợi nhuận, doanh số bán hàng, doanh thu trung bình theo nhóm hàng trong Quý 4 năm 2017 tại Việt Nam
	SELECT [Sub-Category],  Count(*) AS Number_of_Order,
		SUM(Quantity) AS SUM_Quantity, 
		SUM(Profit) AS SUM_Profit,
		SUM(Sales) AS SUM_Sales, 
		AVG(Sales) AS AVG_Sales
	FROM Bills
		INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID]
		INNER JOIN Location ON Bills.LocationID = Location.LocationID
		where Country = 'Vietnam' 
			and month([Order Date]) between 10 and 12
			and  Year([Order Date]) = 2017
	GROUP BY [Sub-Category]

--Q6.Sản phẩm có lợi nhuận > 1000 vào năm 2014 tại thị trường Châu Á Thái Bình Dương
	SELECT [Product Name], SUM(Profit) AS SUM_Profit INTO Products_over_1000_profit_in_ASia_Pacific
	FROM ((Bills
		INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID])
		INNER JOIN Location ON Bills.LocationID = Location.LocationID) 
	where Market = 'ASia Pacific' and Year([Order Date]) = 2014 
	GROUP BY [Product Name]
	Having SUM(Profit) > 1000

	SELECT * FROM Products_over_1000_profit_in_ASia_Pacific ORDER BY SUM_Profit DESC

--Q7.Số lượng đơn hàng theo từng chế độ ship hàng
	SELECT Category, [Ship Mode], count(*) AS Amount INTO [Amount bills by ship mode]
	FROM Bills full outer join Products
	ON Bills.[Product ID] = Products.[Product ID]
		GROUP BY Category, [Ship Mode]
		ORDER BY Category 
	SELECT * FROM [Amount bills by ship mode]

--Q8: Top 10 nước có số đơn hàng nhiều nhất
	SELECT top 10 Country, count(*) AS Amount
	FROM (Bills INNER JOIN Location ON Bills.LocationID = Location.LocationID)
	GROUP BY Country
	ORDER BY COUNT(*) DESC

--Q9.Số lượng sản phẩm từng loại mặt hàng dựa trên phân khúc khách hàng
	SELECT Segment,Category,SUM(Quantity) AS Amount 
	FROM Bills
		INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID]
		INNER JOIN Customers ON Bills.[Customer ID] = Customers.[Customer ID]
		GROUP BY Segment,Category
		ORDER BY Segment

--Q10.Số lượng đơn bán ra mỗi năm theo phân khúc khách hàng.
	DROP TABLE IF EXISTS Amount_bills_by_segment;
	SELECT Segment,
		COUNT(CASE WHEN YEAR([Ship Date])= 2014 THEN 1 END) AS Amount_2014,
		COUNT(CASE WHEN YEAR([Ship Date])= 2015 THEN 1 END) AS Amount_2015,
		COUNT(CASE WHEN YEAR([Ship Date])= 2016 THEN 1 END) AS Amount_2016,
		COUNT(CASE WHEN YEAR([Ship Date])= 2017 THEN 1 END) AS Amount_2017
		INTO Amount_bills_by_segment
		FROM (Bills INNER JOIN Customers ON Bills.[Customer ID] = Customers.[Customer ID])
		GROUP BY Segment
		ORDER BY Segment
	SELECT * FROM Amount_bills_by_segment

	
