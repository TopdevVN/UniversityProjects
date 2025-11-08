create database GlobalShop
use GlobalShop

select top 50 * from Orders

--Fix Postal Code
	update Orders
	set [Postal Code] = iif([Postal Code] is null, ' ', [Postal Code])
	
	select top 50 [Postal Code] from Orders

	alter Table Orders
	alter column [Postal Code] nvarchar(255)

--Add LocationID and Set LocationID's values
	alter table Orders
	add LocationID nvarchar(255) 

	update Orders
	set LocationID = Country + [Postal Code] + City + State

	alter table Orders
	alter column LocationID nvarchar(255) not null

--##create table Location
	select distinct LocationID, Country, State, City, Region,[Postal Code], Market
	into Location
	from Orders
		--##add primary key
		alter table Location
		add primary key (LocationID)

--create table Customers
	select distinct [Customer ID], [Customer Name], Segment 
	into Customers 
	from Orders
	--change data type
	alter table Customers
	alter column [Customer ID] nvarchar(255) not null
	--add primary key
	alter table Customers
	add primary key ([Customer ID])

--create table Products
	select distinct [Product ID], [Product Name], [Sub-Category], Category
	into Products
	from Orders
	--change data type
	alter table Products
	alter column [Product ID] nvarchar(255) not null
	--add primary key
	alter table Products
	add primary key ([Product ID])

--create table Bills
	select [Row ID], [Order ID], [Order Date], [Ship Date], [Ship Mode],
	[Customer ID], [Product ID], Sales, Quantity, Discount, Profit,
	[Shipping Cost],[Order Priority], LocationID
	into Bills from Orders

	--change data type of main column
	alter table Bills
	alter column [Row ID] int not null
	--add primary key
	alter table Bills
	add primary key ([Row ID])


--add foreign key
	alter table Bills
	add constraint FK_Customers foreign key ([Customer ID]) references Customers ([Customer ID]),
	constraint FK_Products foreign key ([Product ID]) references Products ([Product ID]),
	constraint FK_Location foreign key (LocationID) references Location (LocationID)


--TRUY VẤN DỮ LIỆU--

--Q1: Tính doanh thu hàng tháng qua từng năm
--select value
	select month([Ship Date]) as Months,
	       year([Ship Date]) as Years,
		   Sales, Profit 
	into Revenue from Bills
	select * from Revenue
	order by Years, Months
--Tính doanh thu từng tháng qua các năm
	SELECT Months , 
	round(SUM(CASE WHEN Years = 2014 THEN Sales END),2) as [Sum_sale 2014],
	round(SUM(CASE WHEN Years = 2015 THEN Sales END),2) as [Sum_sale 2015],
	round(SUM(CASE WHEN Years = 2016 THEN Sales END),2) as [Sum_sale 2016],
	round(SUM(CASE WHEN Years = 2017 THEN Sales END),2) as [Sum_sale 2017]
	into Sum_sales_by_months_in_4_years
	from Revenue
	group by Months
	order by Months 

select * from Sum_sales_by_months_in_4_years order by Months

--Q2: Lợi nhuận trung bình trên một đơn hàng theo từng tháng mỗi năm

/* Short & easy version
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
SELECT * FROM AVG_PROFIT_PERORDER_OV4YEARS
ORDER BY Months

/*SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Profit_by_months_of_4_years'*/

SELECT Months , 
		round(SUM(CASE WHEN Years = 2014 THEN Profit END)/count(CASE WHEN Years = 2014 THEN 1 END),0) 
		as [Profit_each_bill_2014],
		round(SUM(CASE WHEN Years = 2015 THEN Profit END)/count(CASE WHEN Years = 2015 THEN 1 END),0) 
		as [Profit_each_bill_2015],
		round(SUM(CASE WHEN Years = 2016 THEN Profit END)/count(CASE WHEN Years = 2016 THEN 1 END),0) 
		as [Profit_each_bill_2016],
		round(SUM(CASE WHEN Years = 2017 THEN Profit END)/count(CASE WHEN Years = 2017 THEN 1 END),0) 
		as [Profit_each_bill_2017]
	into Profit_by_months_of_4_years
	from Revenue
	group by Months
	order by Months 

alter table Profit_by_months_of_4_years
alter column Months char(2)

select * from Profit_by_months_of_4_years
order by Months 

select * into Average_profit_by_years
from Profit_by_months_of_4_years
union
select 'Average',
		round(AVG(Profit_each_bill_2014),0),
		round(AVG(Profit_each_bill_2015),0),
		round(AVG(Profit_each_bill_2016),0),
		round(AVG(Profit_each_bill_2017),0)
from Profit_by_months_of_4_years
order by Months

select * from Average_profit_by_years 


----Q3.Sản phẩm có lợi nhuận âm năm 2016
Select distinct [Product Name], sum(profit) as Profit_sum 
into [Product negative profit 1000]
from Bills inner join Products on Bills.[Product ID] = Products.[Product ID]
	where Year([Order Date]) = 2016
	group by [Product Name]
	having sum(Profit) < -1000
	Order by Sum(profit)

select * from [Product negative profit 1000] order by Profit_sum DESC

--Q4.Top 5 quốc gia có lợi nhuận từ điện thoại cao nhất Đông Nam Á năm 2017
Select distinct Country, Sum(Profit) as Sum_Profit 
into Top_5_nations_highest_profit_of_Phones
from Bills
	 INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID]
	 INNER JOIN Location ON Bills.LocationID = Location.LocationID
		where Region = 'Southeastern Asia' and [Sub-Category] = 'Phones' and Year([Order Date]) = 2017
		group by Country
		having Sum(Profit) > 0
		order by Sum(Profit) DESC
-- Thuc te chi co 7 quoc gia
select top 5.* from Top_5_nations_highest_profit_of_Phones order by Sum_Profit DESC


--Q5.Số lượng đơn đặt hàng, tổng số lượng, lợi nhuận, doanh số bán hàng, doanh thu trung bình theo nhóm hàng trong Quý 4 năm 2017 tại Việt Nam
	Select [Sub-Category],  Count(*) as Number_of_Order,
		Sum(Quantity) as Sum_Quantity, 
		Sum(Profit) as Sum_Profit,
		Sum(Sales) as Sum_Sales, 
		AVG(Sales) as AVG_Sales
	from Bills
		INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID]
		INNER JOIN Location ON Bills.LocationID = Location.LocationID
		where Country = 'Vietnam' 
			and month([Order Date]) between 10 and 12
			and  Year([Order Date]) = 2017
	group by [Sub-Category]

--Q6.Sản phẩm có lợi nhuận > 1000 vào năm 2014 tại thị trường Châu Á Thái Bình Dương
	Select [Product Name], Sum(Profit) as Sum_Profit into Products_over_1000_profit_in_Asia_Pacific
	from ((Bills
		INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID])
		INNER JOIN Location ON Bills.LocationID = Location.LocationID) 
	where Market = 'Asia Pacific' and Year([Order Date]) = 2014 
	Group by [Product Name]
	Having Sum(Profit) > 1000

	select * from Products_over_1000_profit_in_Asia_Pacific order by Sum_Profit DESC

--Q7.Số lượng đơn hàng theo từng chế độ ship hàng
	select Category, [Ship Mode], count(*) as Amount into [Amount bills by ship mode]
	from Bills full outer join Products
	on Bills.[Product ID] = Products.[Product ID]
		Group by Category, [Ship Mode]
		order by Category 
	select * from [Amount bills by ship mode]

--Q8: Top 10 nước có số đơn hàng nhiều nhất
	select top 10 Country, count(*) as Amount
	from (Bills INNER JOIN Location ON Bills.LocationID = Location.LocationID)
	group by Country
	order by count(*) DESC

--Q9.Số lượng sản phẩm từng loại mặt hàng dựa trên phân khúc khách hàng
	select Segment,Category,sum(Quantity) as Amount 
	from Bills
		INNER JOIN Products ON Bills.[Product ID] = Products.[Product ID]
		INNER JOIN Customers ON Bills.[Customer ID] = Customers.[Customer ID]
		group by Segment,Category
		order by Segment

--Q10.Số lượng đơn bán ra mỗi năm theo phân khúc khách hàng.
	DROP TABLE IF EXISTS Amount_bills_by_segment;
	select Segment,
		COUNT(CASE WHEN year([Ship Date])= 2014 THEN 1 END) as Amount_2014,
		COUNT(CASE WHEN year([Ship Date])= 2015 THEN 1 END) as Amount_2015,
		COUNT(CASE WHEN year([Ship Date])= 2016 THEN 1 END) as Amount_2016,
		COUNT(CASE WHEN year([Ship Date])= 2017 THEN 1 END) as Amount_2017
		into Amount_bills_by_segment
		from (Bills INNER JOIN Customers ON Bills.[Customer ID] = Customers.[Customer ID])
		group by Segment
		order by Segment
	select * from Amount_bills_by_segment

	
