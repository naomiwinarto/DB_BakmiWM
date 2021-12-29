USE BakmiWM

--1
SELECT c.CustomerID, CustomerName, [Total Transaction] = CAST(COUNT(MenuTranID) AS VARCHAR) + ' purchase(s)'
FROM
	MenuTransaction mt
	JOIN Customer c
	ON c.CustomerID = mt.CustomerID
	JOIN Staff s
	ON s.StaffID = mt.StaffID
WHERE c.CustomerName LIKE '%e%' AND s.StaffName LIKE '%n'
GROUP BY c.CustomerID, CustomerName

--2
SELECT 
	st.SouvenirTranID, 
	StaffID, 
	c.CustomerID, 
	[Total Price] = 'Rp. ' + CAST(SUM(SellPrice * Qty) AS VARCHAR)
FROM
	SouvenirTranDetail std 
	JOIN SouvenirTransaction st
	ON std.SouvenirTranID = st.SouvenirTranID
	JOIN Souvenir sv
	ON std.SouvenirID = sv.SouvenirID
	JOIN Customer c
	ON st.CustomerID = c.CustomerID
WHERE 
	LEN(CustomerName) > 10 AND SellPrice > 35000
GROUP BY
	st.SouvenirTranID, 
	StaffID, 
	c.CustomerID

--3
SELECT 
	mt.MenuTranID,
	CustomerName,
	[MenuTransactionDate] = CONVERT(VARCHAR, MenuTranDate, 105),
	[Total Product] = COUNT(MenuID),
	[Total Quantity] = SUM(Qty)
FROM
	MenuTransaction mt
	JOIN Customer c
	ON mt.CustomerID = c.CustomerID
	JOIN MenuTranDetail mtd
	ON mt.MenuTranID = mtd.MenuTranID
WHERE 
	DAY(MenuTranDate)%2 = 0 AND CustomerName LIKE '% %'
GROUP BY
	mt.MenuTranID, 
	CustomerName, 
	MenuTranDate

--4
SELECT 
	st.SouvenirTranID,
	[Staff First Name] = LEFT(StaffName, CHARINDEX(' ', StaffName)),
	[Total Product] = COUNT(SouvenirID),
	[Total Quantity] = SUM(Qty)
FROM
	SouvenirTransaction st
	JOIN Staff s
	ON st.StaffID = s.StaffID
	JOIN SouvenirTranDetail std
	ON st.SouvenirTranID = std.SouvenirTranID
WHERE 
	StaffName LIKE '% %' AND StaffSalary > 10000000
GROUP BY
	st.SouvenirTranID, 
	StaffName
	
--5
SELECT DISTINCT
	st.SouvenirTranID,
	StaffName,
	[SouvenirTransactionDate] = CONVERT(VARCHAR, SouvenirTranDate, 105),
	[Salary] = 'Rp. ' + CAST(StaffSalary AS VARCHAR)
FROM
	SouvenirTransaction st
	JOIN Staff s
	ON st.StaffID = s.StaffID
	JOIN SouvenirTranDetail std
	ON st.SouvenirTranID = std.SouvenirTranID
	JOIN Souvenir sv
	ON std.SouvenirID = sv.SouvenirID,
	(
		SELECT
			[Average] = AVG(StaffSalary)
		FROM
			Staff
	) AS x
WHERE BuyPrice > 10000 AND StaffSalary > x.Average
GROUP BY
	st.SouvenirTranID,
	StaffName,
	SouvenirTranDate,
	StaffSalary

--6
SELECT
	StaffName,
	MenuName,
	[MenuTransactionDate] = CONVERT(VARCHAR, MenuTranDate, 105),
	[Staff Local Phone] = STUFF(StaffPhone, 1, 1, '+62')
FROM
	MenuTransaction mt
	JOIN Staff s
	ON mt.StaffID = s.StaffID
	JOIN MenuTranDetail mtd
	ON mt.MenuTranID = mtd.MenuTranID
	JOIN Menu m
	ON mtd.MenuID = m.MenuID,
	(
		SELECT
			[Average] = AVG(SellPrice)
		FROM
			Souvenir
	) AS y
WHERE StaffGender = 'Female' AND MenuPrice > y.Average
GROUP BY
	StaffName,
	MenuName,
	MenuTranDate,
	StaffPhone

--8
SELECT
	[Staff Number] = REPLACE(s.StaffID, 'SF', 'Staff'),
	StaffName,
	positionName,
	[Total Quantity] = CAST(SUM(Qty) AS VARCHAR)
FROM
	Staff s
	JOIN Position p
	ON s.PositionID = p.PositionID
	JOIN MenuTransaction mt
	ON s.StaffID = mt.StaffID
	JOIN MenuTranDetail mtd
	ON mt.MenuTranID = mtd.MenuTranID,
	(
		SELECT
			[Minimum] = CAST(MIN(Qty) AS VARCHAR)
		FROM
			MenuTranDetail
	) AS b,
	(
		SELECT
			[Total Quantity] = CAST(SUM(Qty) AS VARCHAR)
		FROM
			MenuTranDetail
	) AS c
WHERE
	[Total Quantity] <= b.Minimum AND DAY(MenuTranDate) BETWEEN 16 AND 25
GROUP BY
	s.StaffID,
	StaffName,
	positionName
