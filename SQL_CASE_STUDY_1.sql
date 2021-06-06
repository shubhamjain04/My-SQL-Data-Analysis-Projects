/* ------------------------------------ "SQL CASE STUDY - RETAIL DATA ANALYSIS" ---------------------------------------------- */
/*-------------------------------------"shubhamjainxyz@gmail.com - BA360 AUG'20 BATCH"---------------------------------------- */
/* ------------------------------------ "DATA PREPARATION" ------------------------------------------------------------------- */


-- Q1. What is the total number of rows in each of the 3 tables in the database?

SELECT 'TBL_CUSTOMER' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS 
FROM TBL_CUSTOMER
UNION ALL
SELECT 'TBL_PROD_CAT', COUNT(*) AS NO_OF_RECORDS 
FROM TBL_PROD_CAT
UNION ALL
SELECT 'TBL_TRANSACTIONS', COUNT(*) AS NO_OF_RECORDS 
FROM TBL_TRANSACTIONS 


-- Q2. What is the total number of transactions that have a return?

SELECT COUNT(TRANSACTION_ID) AS TOTAL_NO_OF_RETURNS
FROM TBL_TRANSACTIONS
WHERE QTY < 0;

-- Q3. As you would have noticed, the dates provided across the datasets are not in a
--    correct format. As first steps, pls convert the date variables into valid date formats
--    before proceeding ahead.

SELECT DOB, CONVERT(DATE, DOB, 103) AS ACTUAL_DOB, TRAN_DATE,CONVERT(DATE, TRAN_DATE, 103) AS ACTUAL_TRAN_DATE
FROM TBL_CUSTOMER AS T1 
INNER JOIN TBL_TRANSACTIONS AS T2 ON T1.CUSTOMER_ID = T2.CUST_ID

-- Q4. What is the time range of the transaction data available for analysis? Show the
--     output in number of days, months and years simultaneously in different columns. 

SELECT DATEDIFF(DAY, MIN(CONVERT(DATE, TRAN_DATE, 103)), MAX(CONVERT(DATE, TRAN_DATE, 103))) AS TIME_RANGE_DAYS,
       DATEDIFF(MONTH, MIN(CONVERT(DATE, TRAN_DATE, 103)), MAX(CONVERT(DATE, TRAN_DATE, 103))) AS TIME_RANGE_MONTHS,
	   DATEDIFF(YEAR, MIN(CONVERT(DATE, TRAN_DATE, 103)), MAX(CONVERT(DATE, TRAN_DATE, 103))) AS TIME_RANGE_YEARS
FROM TBL_TRANSACTIONS;

-- Q5. Which product category does the sub-category “DIY” belong to?

SELECT PROD_CAT
FROM TBL_PROD_CAT
WHERE PROD_SUBCAT = 'DIY';

/* --------------------------------------- " DATA ANALYSIS " ---------------------------------------------- */

-- Q1. Which channel is most frequently used for transactions?

SELECT TOP 1 STORE_TYPE, COUNT(STORE_TYPE) AS COUNT_OF_TRANSACTIONS
FROM TBL_TRANSACTIONS
GROUP BY STORE_TYPE
ORDER BY COUNT(STORE_TYPE) DESC;

-- Q2. What is the count of Male and Female customers in the database?

SELECT SUM(NO_OF_MALES) AS NO_OF_MALES, SUM(NO_OF_FEMALES) AS NO_OF_MALES
FROM(
      SELECT CASE WHEN GENDER = 'M' THEN COUNT(GENDER) ELSE 0 END AS NO_OF_MALES,
             CASE WHEN GENDER = 'F' THEN COUNT(GENDER) ELSE 0 END AS NO_OF_FEMALES
      FROM TBL_CUSTOMER
      GROUP BY GENDER
	) AS T1;

-- Q3. From which city do we have the maximum number of customers and how many?

SELECT TOP 1 CITY_CODE, COUNT(CUSTOMER_ID) AS NO_OF_CUSTOMERS
FROM TBL_CUSTOMER
GROUP BY CITY_CODE
ORDER BY NO_OF_CUSTOMERS DESC;

-- Q4. How many sub-categories are there under the Books category?

SELECT PROD_CAT, COUNT(PROD_SUBCAT) AS NO_OF_SUBCATEGORIES
FROM TBL_PROD_CAT
WHERE PROD_CAT LIKE 'BOOKS'
GROUP BY PROD_CAT;
           
-- Q5. What is the maximum quantity of products ever ordered ?

SELECT TOP 1 SUM(CAST(QTY AS FLOAT)) AS MAX_QTY_OF_PROD_ORDERED
FROM TBL_TRANSACTIONS
WHERE QTY > 0
GROUP BY TRANSACTION_ID
ORDER BY SUM(CAST(QTY AS FLOAT)) DESC;

-- Q6. What is the net total revenue generated in categories Electronics and Books ?

SELECT T1.PROD_CAT, SUM(CAST(TOTAL_AMT AS FLOAT)) AS NET_TOTAL_REVENUE
FROM TBL_PROD_CAT AS T1 
     INNER JOIN TBL_TRANSACTIONS AS T2 
     ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE 
     AND T1.PROD_SUB_CAT_CODE = T2.PROD_SUBCAT_CODE
WHERE T1.PROD_CAT IN ('BOOKS', 'ELECTRONICS') AND CAST(TOTAL_AMT AS FLOAT) > 0
GROUP BY T1.PROD_CAT;

-- Q7. How many customers have > 10 transactions with us, excluding returns ?

SELECT COUNT(*) AS NO_OF_CUSTOMERS_WITH_MORE_THAN_TEN_TRANSACTIONS
FROM(
     SELECT T1.CUSTOMER_ID, COUNT(TRANSACTION_ID) AS NO_OF_TRANSACTIONS
     FROM TBL_CUSTOMER AS T1 INNER JOIN TBL_TRANSACTIONS AS T2 ON T1.CUSTOMER_ID = T2.CUST_ID
     WHERE T2.QTY > 0
     GROUP BY T1.CUSTOMER_ID
     HAVING COUNT(TRANSACTION_ID) > 10
    ) AS T3

-- Q8. What is the combined revenue earned from the “Electronics” & “Clothing”
--     categories, from “Flagship stores” ?

SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS COMBINED_TOTAL_REVENUE 
FROM TBL_PROD_CAT AS T1 INNER JOIN TBL_TRANSACTIONS AS T2 
     ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE 
     AND T1.PROD_SUB_CAT_CODE = T2.PROD_SUBCAT_CODE
WHERE T1.PROD_CAT IN ('ELECTRONICS', 'CLOTHING') AND T2.STORE_TYPE = 'FLAGSHIP STORE' AND QTY > 0

-- Q9. What is the total revenue generated from “Male” customers in “Electronics”
--     category? Output should display total revenue by prod sub-cat.

SELECT T3.PROD_SUBCAT, SUM(CAST(T2.TOTAL_AMT AS FLOAT)) AS TOTAL_REVENUE_MALE_CUST
FROM TBL_CUSTOMER AS T1 
     INNER JOIN TBL_TRANSACTIONS AS T2 ON T1.CUSTOMER_ID = T2.CUST_ID 
     INNER JOIN TBL_PROD_CAT AS T3 ON T2.PROD_CAT_CODE = T3.PROD_CAT_CODE 
	            AND T2.PROD_SUBCAT_CODE = T3.PROD_SUB_CAT_CODE
WHERE T1.GENDER = 'M' AND T3.PROD_CAT = 'ELECTRONICS' AND QTY > 0
GROUP BY T3.PROD_SUBCAT;
  
-- Q10. What is percentage of sales and returns by product sub category; display only top
--      5 sub categories in terms of sales ?

SELECT TOP 5 PROD_SUBCAT, SUM(PERCENTAGE_OF_SALES) AS PERCENTAGE_OF_SALES, SUM(PERCENTAGE_OF_RETURN) AS PERCENTAGE_OF_RETURN
FROM(
     SELECT T1.PROD_SUBCAT,
     CASE
	 WHEN CAST(QTY AS INT) > 0
	 THEN (SUM(CAST(T2.TOTAL_AMT AS FLOAT))*100/(SELECT(SUM(CAST(TOTAL_AMT AS FLOAT))) FROM TBL_TRANSACTIONS WHERE CAST(QTY AS INT) > 0))
	 END AS PERCENTAGE_OF_SALES,
	 CASE
	 WHEN QTY < 0
	 THEN (SUM(CAST(T2.TOTAL_AMT AS FLOAT))*100/(SELECT(SUM(CAST(TOTAL_AMT AS FLOAT))) FROM TBL_TRANSACTIONS WHERE CAST(QTY AS INT) < 0))
	 END AS PERCENTAGE_OF_RETURN
     FROM TBL_PROD_CAT AS T1 
     INNER JOIN TBL_TRANSACTIONS AS T2 ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE
	            AND T1.PROD_SUB_CAT_CODE = T2.PROD_SUBCAT_CODE
     GROUP BY T1.PROD_SUBCAT, QTY 
    ) AS TT
GROUP BY PROD_SUBCAT 
ORDER BY PERCENTAGE_OF_SALES DESC;

-- Q11. For all customers aged between 25 to 35 years find what is the net total revenue
--      generated by these consumers in last 30 days of transactions from max transaction
--      date available in the data?

SELECT SUM(CAST(TOTAL_AMT AS FLOAT)) AS NET_TOTAL_REVENUE 
FROM TBL_TRANSACTIONS AS T1 
     INNER JOIN TBL_CUSTOMER AS T2 ON T1.CUST_ID = T2.CUSTOMER_ID 
WHERE CONVERT(DATE, T2.DOB, 103) BETWEEN (SELECT DATEADD(YEAR, -35, GETDATE())) AND (SELECT DATEADD(YEAR, -25, GETDATE()))                                          
      AND T1.QTY > 0 AND                            			                          
	  CONVERT(DATE, T1.TRAN_DATE, 103) BETWEEN (SELECT DATEADD(DAY, -30, MAX(CONVERT(DATE, TRAN_DATE, 103))) FROM TBL_TRANSACTIONS)							
									       AND (SELECT MAX(CONVERT(DATE, TRAN_DATE, 103)) FROM TBL_TRANSACTIONS) 
											      									              				                          								
-- Q12. Which product category has seen the max value of returns in the last 3 months of
--      transactions?

SELECT TOP 1 PROD_CAT, T1.PROD_CAT_CODE, SUM(CAST(TOTAL_AMT AS FLOAT)) AS VALUE_OF_RETURN
FROM TBL_TRANSACTIONS AS T1 
     INNER JOIN TBL_PROD_CAT AS T2 ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE
	 AND T1.PROD_SUBCAT_CODE = T2.PROD_SUB_CAT_CODE
WHERE CAST(TOTAL_AMT AS FLOAT) < 0
GROUP BY T2.PROD_CAT, T1.PROD_CAT_CODE, CONVERT(DATE, TRAN_DATE, 103) 
HAVING CONVERT(DATE, TRAN_DATE, 103) 
       BETWEEN DATEADD(MONTH, -3, MAX(CONVERT(DATE, TRAN_DATE, 103)))
	   AND MAX(CONVERT(DATE, TRAN_DATE, 103)) 
ORDER BY VALUE_OF_RETURN 

-- Q13. Which store-type sells the maximum products; by value of sales amount and by
--      quantity sold?

SELECT STORE_TYPE, SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_SALES, SUM(CAST(QTY AS FLOAT)) AS TOAL_QUANTITY
FROM TBL_TRANSACTIONS
WHERE CAST(TOTAL_AMT AS FLOAT) > 0
GROUP BY STORE_TYPE 
HAVING SUM(CAST(TOTAL_AMT AS FLOAT)) = (
                                        SELECT TOP 1 SUM(CAST(TOTAL_AMT AS FLOAT))
                                        FROM TBL_TRANSACTIONS 
										WHERE CAST(TOTAL_AMT AS FLOAT) > 0
                                        GROUP BY STORE_TYPE 
                                        ORDER BY SUM(CAST(TOTAL_AMT AS FLOAT)) DESC
									   )
									   AND
       SUM(CAST(QTY AS FLOAT))      = (
                                        SELECT TOP 1 SUM(CAST(QTY AS FLOAT))
                                        FROM TBL_TRANSACTIONS 
										WHERE CAST(QTY AS FLOAT) > 0
                                        GROUP BY STORE_TYPE 
                                        ORDER BY SUM(CAST(QTY AS FLOAT)) DESC 
									   ) 

-- Q14. What are the categories for which average revenue is above the overall average ?

SELECT T1.PROD_CAT, AVG(CAST(TOTAL_AMT AS FLOAT)) AS AVERAGE_REVENUE
FROM TBL_PROD_CAT AS T1 
     INNER JOIN TBL_TRANSACTIONS AS T2 ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE
	            AND T1.PROD_SUB_CAT_CODE = T2.PROD_SUBCAT_CODE
WHERE CAST(TOTAL_AMT AS FLOAT) > 0
GROUP BY T1.PROD_CAT
HAVING AVG(CAST(TOTAL_AMT AS FLOAT)) > (SELECT AVG(CAST(TOTAL_AMT AS FLOAT)) 
                                       FROM TBL_TRANSACTIONS 
									   WHERE CAST(TOTAL_AMT AS FLOAT) > 0)

-- Q15. Find the average and total revenue by each subcategory for the categories which
--      are among top 5 categories in terms of quantity sold.

SELECT PROD_CAT,PROD_SUBCAT, SUM(CAST(QTY AS FLOAT)) AS QUANTITY_SOLD, 
                             SUM(CAST(TOTAL_AMT AS FLOAT)) AS TOTAL_REVENUE, 
				             AVG(CAST(TOTAL_AMT AS FLOAT)) AS AVERAGE_REVENUE
FROM TBL_PROD_CAT AS T1
     INNER JOIN TBL_TRANSACTIONS AS T2 ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE
	 AND T1.PROD_SUB_CAT_CODE = T2.PROD_SUBCAT_CODE
WHERE QTY > 0 AND PROD_CAT IN (
                               SELECT TOP 5 PROD_CAT
                               FROM TBL_PROD_CAT AS T1
                                    INNER JOIN TBL_TRANSACTIONS AS T2 ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE
									AND T1.PROD_SUB_CAT_CODE = T2.PROD_SUBCAT_CODE
                               WHERE QTY > 0
                               GROUP BY PROD_CAT
                               ORDER BY SUM(CAST(QTY AS FLOAT)) DESC
                              )  
GROUP BY PROD_CAT, PROD_SUBCAT
ORDER BY PROD_CAT,PROD_SUBCAT, SUM(CAST(QTY AS FLOAT)) DESC;



