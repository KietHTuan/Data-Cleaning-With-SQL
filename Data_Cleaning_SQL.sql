/* Step1: Remove irrelevant Data tables by following these sub-steps:
	a. Create a new database for the streamlined data.
	b. Import all necessary tables using SQL Server Import and Export Wizard
	c. Drop unecessary tables from the newly created database 
*/

CREATE DATABASE Ecommerce_Data 
USE Ecommerce_Data
DROP TABLE 
	Currency, CurrencyHistory, ProductCategory, ProductSubcategory, 
	SalesTargets, SaleType, Supplier, sysdiagrams


/* Step2:  assess the ProductSupplier table by:
	a. Ensure no nulls for ProductKey and SupplierKey 
	b. Change LastReceiptCost to two decimals
	c. Format the LastReceiptDate to Date format 
*/

--Check for nulls 
SELECT* FROM ProductSupplier
WHERE ProductKey is null or SupplierKey is null; 

--Change the decimals for LastReceiptCost to two decimals  
SELECT  Round (LastReceiptCost, 2) AS LastReceiptCost2
FROM ProductSupplier

UPDATE ProductSupplier
SET LastReceiptCost =  ROUND (LastReceiptCost, 2);

--Format the LastReceiptDate to Date format 
AlTER TABLE [dbo].[ProductSupplier]
ADD LastReceiptDate2 Date,

UPDATE [dbo].[ProductSupplier]
SET LastReceiptDate2 =  CONVERT(Date, LastReceiptDate)

ALTER TABLE [dbo].[ProductSupplier]
DROP COLUMN LastReceiptDate


/* Step3: assess the OnlineSales table by:
	a. Check nulls for ProductKey, CustomerKey, CurrencyKey 
	b. Populate SaleTypeKey null values from OnlineSalesType table 
*/

--Check for nulls 
SELECT* FROM [dbo].[OnlineSales]
WHERE ProductKey is null or CustomerKey is null or CurrencyKey is null;

--Populate the SaleTypeKey null values 
SELECT* FROM [dbo].[OnlineSales]
WHERE SaleTypeKey is null ORDER BY SalesOrderNumber

SELECT * FROM [dbo].[OnlineSalesType]
ORDER BY SalesOrderNumber --We can see that there are some missing SalesOrderNumber values associated with their nulls  



/* Step4: assess the Customer table by: 
	a. Check nulls/duplicates for CustomerKey, CustomerAlternateKey columns 
	b. Remove NameStyle and Suffix columns 
	c. Remove ".00" for Yearly Income column 
	d. Create a new column to extract the name from the email domain in EmailAddress column 
*/
SELECT* FROM Customer

--Check for nulls 
SELECT* FROM Customer
WHERE CustomerKey is null or CustomerAlternateKey is null;

--Check for duplicates 
SELECT CustomerKey, CustomerAlternateKey, COUNT (*) as Count1
FROM Customer
GROUP BY CustomerKey, CustomerAlternateKey
HAVING COUNT (*) > 1; 

--Remove NameStyle and Suffix columns 
ALTER TABLE [dbo].[Customer] 
DROP COLUMN NameStyle, Suffix;

--Remove ".00" in the YearlyIncome column
SELECT CONVERT (double precision, yearlyincome) FROM customer as NoDecimals

--Extract name from email domain in the EmailAddress column 
SELECT REPLACE (EmailAddress, '@awari.com.au' , ' ' ) as RemovedDomain
FROM Customer

ALTER TABLE [dbo].[Customer]
ADD  RemovedDomain Nvarchar(15)

UPDATE Customer
SET RemovedDomain = REPLACE (EmailAddress, '@awari.com.au' , ' ' )



/* Step5: assess the ProductInventory table by:
	a. Check for Nulls/Duplicates for ProductKey, DateKey
	b. Remove StockTakeFlag column
	c. Create a Status column as following:
		If StockOnHand  0-30: Low
			            30-100: Moderate
						100-250: Good
						250+ : Excellent 
*/

Select* from ProductInventory 

--Check for nulls 
SELECT* FROM ProductInventory Inv inner join Product prd
	ON inv.ProductKey = prd.ProductKey
	
WHERE inv.ProductKey is null or DateKey is null;


--Remove StockTakeFlag column 
ALTER TABLE [dbo].[ProductInventory]
DROP COLUMN StockTakeFlag

--Create a Status column 
SELECT
	Inv.ProductKey,
	Inv.DateKey,
	Inv.StockTxnDate,
	Inv.UnitCost,
	Inv.StockIn,
	Inv.StockOut,
	Inv.StockOnHand,
	CASE 
	WHEN StockOnHand between 0 and 30 then 'Low'
	WHEN StockOnHand between 30 and 100 then 'Moderate'
	WHEN StockOnHand between 100 and 250 then 'Good'
	ELSE  'Excellent'
END AS InventoryStatus 

FROM  ProductInventory Inv inner join Product prd
	ON inv.ProductKey = prd.ProductKey
	


