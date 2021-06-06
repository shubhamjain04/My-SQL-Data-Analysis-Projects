/* ---------- SQL CASE STUDY - VERY ADVANCE ----------------- */

USE SQL_CASE_STUDY;

select *
from CUSTOMER

select * 
from ORDERITEM

select *
from ORDERS

select *
from PRODUCT

select *
from SUPPLIER


-- Q1. List all customers.
SELECT *
FROM CUSTOMER

-- Q2. List the first name, last name, and city of all customers.
SELECT FirstName, LastName, City 
FROM CUSTOMER

-- Q3. List the customers in Sweden. Remember it is "Sweden" and NOT "sweden" because filtering
--     value is case sensitive in Redshift.
SELECT *
FROM CUSTOMER
WHERE Country LIKE 'Sweden'

-- Q4. Create a copy of Supplier table. Update the city to Sydney for supplier starting with letter P.
SELECT *
INTO SUPPLIER_COPY
FROM SUPPLIER 

UPDATE SUPPLIER_COPY
SET City = 'Sydney'
WHERE ContactName LIKE 'P%'

SELECT *
FROM SUPPLIER_COPY

-- Q5. Create a copy of Products table and Delete all products with unit price higher than $50.
SELECT * 
INTO PRODUCT_COPY
FROM PRODUCT 
WHERE CAST(UnitPrice AS FLOAT) < 50

SELECT *
FROM PRODUCT_COPY

-- Q6. List the number of customers in each country.
SELECT Country, COUNT(*) AS No_Of_Customers
FROM CUSTOMER
GROUP BY Country

-- Q7. List the number of customers in each country sorted high to low.
SELECT Country, COUNT(*) AS No_Of_Customers
FROM CUSTOMER
GROUP BY Country
ORDER BY No_Of_Customers DESC

-- Q8. List the total amount for items ordered by each customer.
SELECT A.Id, FirstName, LastName, SUM(CAST(TotalAmount AS FLOAT)) AS TOTAL_AMOUNT
FROM CUSTOMER A, ORDERS B
WHERE A.Id = B.CustomerId
GROUP BY A.Id, FirstName, LastName
ORDER BY CAST(A.Id AS INT)

-- Q9. List the number of customers in each country. Only include countries with more than 10 customers.
SELECT *
FROM ( 
        SELECT Country, COUNT(*) AS No_of_Customers
        FROM CUSTOMER
        GROUP BY Country
	 ) T1
WHERE No_of_Customers > 10

-- Q10. List the number of customers in each country, except the USA, sorted high to low. Only
--      include countries with 9 or more customers.
SELECT *
FROM ( 
        SELECT Country, COUNT(*) AS No_of_Customers
        FROM CUSTOMER
		WHERE Country NOT LIKE 'USA'
        GROUP BY Country
	 ) T1
WHERE No_of_Customers >= 9
ORDER BY No_of_Customers DESC

-- Q11. List all customers whose first name or last name contains "ill".
SELECT *
FROM CUSTOMER 
WHERE FirstName LIKE '%ill%' OR LastName LIKE '%ill%'

-- Q12. List all customers whose average of their total order amount is between $1000 and
--      $1200.Limit your output to 5 results.
SELECT TOP 5 *
FROM (
      SELECT A.Id, FirstName, LastName, AVG(CAST(TotalAmount AS FLOAT)) AS AVG_TOTAL_AMOUNT
      FROM CUSTOMER A, ORDERS B
      WHERE A.Id = B.CustomerId 
      GROUP BY A.Id, FirstName, LastName
     ) T1
WHERE CAST(AVG_TOTAL_AMOUNT AS FLOAT) BETWEEN 1000 AND 1200 

-- Q13. List all suppliers in the 'USA', 'Japan', and 'Germany', ordered by country from A-Z, and then
--      by company name in reverse order.
SELECT *
FROM SUPPLIER 
WHERE Country = 'USA' OR Country = 'Japan' OR Country = 'Germany'
ORDER BY Country, CompanyName DESC

-- Q14. Show all orders, sorted by total amount (the largest amount first), within each year.
SELECT *
FROM ORDERS
ORDER BY YEAR(OrderDate), TotalAmount DESC

-- Q15. Products with UnitPrice greater than 50 are not selling despite promotions. You are asked to
--      discontinue products over $25. Write a query to relfelct this. Do this in the copy of the Product
--      table. DO NOT perform the update operation in the Product table.
DROP TABLE PRODUCT_COPY

SELECT *, CASE WHEN IsDiscontinued = 'FALSE' THEN 'TRUE' END  AS IsDiscontinued2
INTO PRODUCT_COPY
FROM PRODUCT 
WHERE CAST(UnitPrice AS FLOAT) > 25

SELECT *
FROM PRODUCT_COPY

SELECT *
FROM PRODUCT
WHERE CAST(UnitPrice AS FLOAT) > 25 

-- Q16. List top 10 most expensive products.
SELECT TOP 10 *
FROM PRODUCT 
ORDER BY CAST(UnitPrice AS FLOAT) DESC

-- ?Q17. Get all but the 10 most expensive products sorted by price.
SAMES AS Q16.

-- Q18. Get the 10th to 15th most expensive products sorted by price.
SELECT *
FROM (
      SELECT ROW_NUMBER() OVER (ORDER BY CAST(UnitPrice AS FLOAT) DESC) AS RNUM, *
      FROM PRODUCT 
     ) T1
WHERE RNUM = 10 OR RNUM = 15

-- Q19. Write a query to get the number of supplier countries. Do not count duplicate values.
SELECT COUNT(DISTINCT(COUNTRY)) AS NO_OF_SUPPLIER_COUNTRIES
FROM SUPPLIER 

-- Q20. Find the total sales cost in each month of the year 2013.
SELECT YEAR(CAST(OrderDate AS DATE)) AS ORDER_YEAR, 
       MONTH(CAST(OrderDate AS DATE)) AS ORDER_MONTH,
	   SUM(CAST(TotalAmount AS FLOAT)) AS TOTAL_AMOUNT
FROM ORDERS
WHERE YEAR(CAST(OrderDate AS DATE)) = 2013
GROUP BY YEAR(CAST(OrderDate AS DATE)), 
         MONTH(CAST(OrderDate AS DATE))

-- Q21. List all products with names that start with 'Ca'.
SELECT *
FROM PRODUCT 
WHERE ProductName LIKE 'Ca%'

-- Q22. List all products that start with 'Cha' or 'Chan' and have one more character.
SELECT *
FROM PRODUCT 
WHERE ProductName LIKE 'Cha_' OR ProductName LIKE 'Chan_'

-- Q23. Your manager notices there are some suppliers without fax numbers. He seeks your help to
--      get a list of suppliers with remark as "No fax number" for suppliers who do not have fax
--      numbers (fax numbers might be null or blank).Also, Fax number should be displayed for
--      suppliers with fax numbers.
SELECT *, CASE WHEN Fax LIKE '' THEN 'No Fax Number' ELSE Fax END AS FAX_STATUS
FROM SUPPLIER

-- Q24. List all orders, their orderDates with product names, quantities, and prices.
SELECT T1.Id AS QRDER_ID, T1.OrderDate, T1.OrderNumber, T2.ProductId, 
       T3.ProductName, T2.Quantity, T2.UnitPrice, 
	   CAST(T2.Quantity AS FLOAT)*CAST(T2.UnitPrice AS FLOAT) AS SUB_TOTAL
FROM ORDERS AS T1 INNER JOIN ORDERITEM AS T2 ON T1.Id = T2.OrderId
                  INNER JOIN PRODUCT AS T3 ON T2.ProductId = T3.Id

-- Q25. List all customers who have not placed any Orders.
SELECT *
FROM CUSTOMER AS T1
WHERE T1.Id NOT IN (
                    SELECT CustomerId
					FROM ORDERS 
				   )

-- ?Q26. List suppliers that have no customers in their country, and customers that have no suppliers
--      in their country, and customers and suppliers that are from the same country.
SELECT T1.FirstName, T1.LastName, T2.CompanyName, T2.ContactName, T2.Country
FROM CUSTOMER AS T1 INNER JOIN SUPPLIER AS T2 ON T1.Country = T2.Country
WHERE T2.Country NOT IN (
                         SELECT Country 
						 FROM CUSTOMER 
						) 
UNION ALL
SELECT T1.FirstName, T1.LastName, T2.CompanyName, T2.ContactName, T2.Country
FROM CUSTOMER AS T1 INNER JOIN SUPPLIER AS T2 ON T1.Country = T2.Country
WHERE T1.Country NOT IN (
                         SELECT Country 
						 FROM SIPPLIER  
						) 
UNION ALL
SELECT T1.FirstName, T1.LastName, T2.CompanyName, T2.ContactName, T2.Country
FROM CUSTOMER AS T1 INNER JOIN SUPPLIER AS T2 ON T1.Country = T2.Country


SELECT *
FROM CUSTOMER AS T2
WHERE T2.Country NOT IN (
                         SELECT Country
						 FROM SUPPLIER 
						)

SELECT * 
FROM CUSTOMER AS T1 INNER JOIN SUPPLIER AS T2 ON T1.Country = T2.Country

-- Q27. Match customers that are from the same city and country. That is you are asked to give a list
--      of customers that are from same country and city. Display firstname, lastname, city and
--      coutntry of such customers.
SELECT Id, FirstName, LastName, Country, City, Phone
FROM CUSTOMER
WHERE City IN (
               SELECT City
			   FROM CUSTOMER 
			   GROUP BY City 
			   HAVING COUNT(City) > 1
			  )
ORDER BY Country, City 

-- ?Q28. List all Suppliers and Customers. Give a Label in a separate column as 'Suppliers' if he is a
--      supplier and 'Customer' if he is a customer accordingly. Also, do not display firstname and
--      lastname as two seperate fields; Display Full name of customer or supplier.
SELECT CONCAT(FirstName, ' ' ,LastName) AS FULL_NAME, LABEL_ = 'CUSTOMER'
FROM CUSTOMER 

-- Q29. Create a copy of orders table. In this copy table, now add a column city of type varchar (40).
--      Update this city column using the city info in customers table.
SELECT *
INTO ORDERS_COPY
FROM ORDERS 

ALTER TABLE ORDERS_COPY
ADD City VARCHAR(20)

SELECT *
FROM ORDERS_COPY

UPDATE ORDERS_COPY
SET City = CUSTOMER.City
WHERE ORDERS_COPY.CustomerId = CUSTOMER.Id

-- Q30. Suppose you would like to see the last OrderID and the OrderDate for this last order that
--      was shipped to 'Paris'. Along with that information, say you would also like to see the
--      OrderDate for the last order shipped regardless of the Shipping City. In addition to this, you
--      would also like to calculate the difference in days between these two OrderDates that you get.
--      Write a single query which performs this.
--      (Hint: make use of max (columnname) function to get the last order date and the output is a
--             single row output.)
SELECT (SELECT T1.Id 
        FROM ORDERS AS T1 INNER JOIN CUSTOMER AS T2 ON T1.CustomerId = T2.Id
		WHERE T2.City LIKE 'Paris'
		GROUP BY T1.Id, T1.OrderDate
		HAVING CAST(T1.OrderDate AS DATE) = (
		                                     SELECT MAX(CAST(T1.OrderDate AS DATE))
                                             FROM ORDERS AS T1 INNER JOIN CUSTOMER AS T2 ON 
											                              T1.CustomerId = T2.Id
                                             WHERE T2.City LIKE 'Paris'
											)
	   ) AS LastOrderID_Paris,

	   (
        SELECT MAX(CAST(T1.OrderDate AS DATE))
        FROM ORDERS AS T1 INNER JOIN CUSTOMER AS T2 ON T1.CustomerId = T2.Id
        WHERE T2.City LIKE 'Paris'
       ) AS LastOrderDate_Paris,

	   (
	    SELECT MAX(CAST(T1.OrderDate AS DATE)) AS LastOrderDate
		FROM ORDERS AS T1
	   ) AS LastOrderDate,

	   DATEDIFF(DAY, 
	           (SELECT MAX(CAST(T1.OrderDate AS DATE))
				FROM ORDERS AS T1 INNER JOIN CUSTOMER AS T2 ON T1.CustomerId = T2.Id
                WHERE T2.City LIKE 'Paris'),
			   (SELECT MAX(CAST(T1.OrderDate AS DATE)) AS LastOrderDate
		         FROM ORDERS AS T1)
			   ) AS DIFFERENCE_IN_DAYS

-- Q31. Find those customer countries who do not have suppliers. This might help you provide
--      better delivery time to customers by adding suppliers to these countires. Use SubQueries.
SELECT Country AS COUNTRIES_WITH_NO_SUPPLIERS
FROM CUSTOMER
WHERE Country NOT IN (
                      SELECT Country 
					  FROM SUPPLIER 
					 )
GROUP BY Country 

-- Q32. Suppose a company would like to do some targeted marketing where it would contact
--      customers in the country with the fewest number of orders. It is hoped that this targeted
--      marketing will increase the overall sales in the targeted country. You are asked to write a query
--      to get all details of such customers from top 5 countries with fewest numbers of orders. Use Subqueries.
SELECT *
FROM CUSTOMER
WHERE Country IN (
                  SELECT  TOP 5 T1.Country
				  FROM CUSTOMER AS T1 INNER JOIN ORDERS AS T2 ON T1.Id = T2.CustomerId
				  GROUP BY  T1.Country
				  ORDER BY COUNT(T2.CustomerId)
				 )

-- ?Q33. Let's say you want report of all distinct "OrderIDs" where the customer did not purchase
--       more than 10% of the average quantity sold for a given product. This way you could review
--       these orders, and possibly contact the customers, to help determine if there was a reason for
--       the low quantity order. Write a query to report such orderIDs.
SELECT T1.Id AS CUST_ID, T1.FirstName, T1.LastName,T2.Id AS ORDER_ID, T3.ProductId, T3.Quantity
       
FROM CUSTOMER AS T1 INNER JOIN ORDERS AS T2 ON T1.Id = T2.CustomerId
                    INNER JOIN ORDERITEM AS T3 ON T2.Id = T3.OrderId
ORDER BY CAST(T1.Id AS INT)

(SELECT AVG(CAST(Quantity AS FLOAT)) FROM ORDERITEM GROUP BY ProductId) AS AVERAGE_QUANTITY_SOLD

-- Q34. Find Customers whose total orderitem amount is greater than 7500$ for the year 2013. The
--      total order item amount for 1 order for a customer is calculated using the formula UnitPrice *
--      Quantity * (1 - Discount). DO NOT consider the total amount column from 'Order' table to
--      calculate the total orderItem for a customer.
SELECT T1.Id, T1.FirstName, T1.LastName, T1.City, T1.Country, T1.Phone, 
       SUM(CAST(T3.Quantity AS FLOAT)*CAST(T3.UnitPrice AS FLOAT)*(1-CAST(T3.Discount AS FLOAT))) AS TOTAL_AMOUNT
FROM CUSTOMER AS T1 INNER JOIN ORDERS AS T2 ON T1.Id = T2.CustomerId
                    INNER JOIN ORDERITEM AS T3 ON T2.Id = T3.OrderId
WHERE YEAR(CAST(T2.OrderDate AS DATE)) = 2013
GROUP BY T1.Id, T1.FirstName, T1.LastName, T1.City, T1.Country, T1.Phone
HAVING SUM(CAST(T3.Quantity AS FLOAT)*CAST(T3.UnitPrice AS FLOAT)*(1 - CAST(T3.Discount AS FLOAT))) > 7500
ORDER BY CAST(T1.Id AS INT)

-- Q35. Display the top two customers, based on the total dollar amount associated with their
--      orders, per country. The dollar amount is calculated as OI.unitprice * OI.Quantity * (1 -
--      OI.Discount). You might want to perform a query like this so you can reward these customers,
--      since they buy the most per country.
SELECT *
FROM (
SELECT ROW_NUMBER() OVER (
	                      PARTITION BY T1.Country
	                      ORDER BY SUM(CAST(T3.Quantity AS FLOAT)*CAST(T3.UnitPrice AS FLOAT)*(1-CAST(T3.Discount AS FLOAT))) DESC
						 ) AS RNUM,
	   T1.Id, T1.FirstName, T1.LastName, T1.City, T1.Country, T1.Phone, SUM(CAST(T2.TotalAmount AS FLOAT)) AS TOTAL_AMOUNT
FROM CUSTOMER AS T1 INNER JOIN ORDERS AS T2 ON T1.Id = T2.CustomerId
                    INNER JOIN ORDERITEM AS T3 ON T2.Id = T3.OrderId
GROUP BY T1.Id, T1.FirstName, T1.LastName, T1.City, T1.Country, T1.Phone
) AS TT
WHERE RNUM = 1 OR RNUM = 2

-- Q36. Create a View of Products whose unit price is above average Price.
CREATE VIEW PRODUCTS_ABOVE_AVERAGE_PRICE AS
SELECT T1.Id, T1.ProductName, T1.UnitPrice
FROM PRODUCT AS T1
GROUP BY T1.Id, T1.ProductName, T1.UnitPrice
HAVING T1.UnitPrice > (
                       SELECT AVG(CAST(UnitPrice AS FLOAT))
					   FROM PRODUCT 
                      )

-- Q37. STORED PROCEDURE QUESTION 
