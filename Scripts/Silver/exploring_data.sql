/*
Purpose of this script:
This scripts checks for null or duplicates in priamry key.
It consists of checking for unwanted spaces, sanity, business rules ensuring the data is accurate and consistent
*/

SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*)>1;

--Checking for unwanted spaces in the string columns
SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE LEN(cst_firstname)<>LEN(TRIM(cst_firstname));

SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE LEN(cst_lastname)<>LEN(TRIM(cst_lastname));

--Checking for consistency in low cardinality columns
SELECT DISTINCT cst_material_status
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

--crm_prd_info

--Checking if there are null or duplicate values in primary key
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id 
HAVING COUNT(*)>1;

--Deriving columns to join tables in gold layer
SELECT 
prd_key,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key
FROM bronze.crm_prd_info

--Checking for leading and trailing spaces in string columns
SELECT 
prd_nm
FROM bronze.crm_prd_info
WHERE LEN(prd_nm)<>LEN(TRIM(prd_nm))

--Checking for NULL OR negative costs 
SELECT 
prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost<0 OR prd_cost IS NULL

--Checking for consistency in low cardinal columns
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info

--Checking for sanity checks in dates
SELECT prd_start_dt, pred_end_dt
FROM Bronze.crm_prd_info
WHERE prd_start_dt > pred_end_dt;

--crm_sales_details

--checking for any unwanted spaces in sls_prd_key column
SELECT sls_prd_key
FROM Bronze.crm_sales_details
WHERE LEN(sls_prd_key)<>LEN(TRIM(sls_prd_key));

--checking the data type of sls_ord_dt
SELECT 
NULLIF(sls_order_dt,0) AS sls_order_dt
FROM Bronze.crm_sales_details
WHERE ISNUMERIC(sls_order_dt) <= 0 OR LEN(sls_order_dt)<>8;

SELECT 
NULLIF(sls_ship_dt,0) AS sls_ship_dt
FROM Bronze.crm_sales_details
WHERE ISNUMERIC(sls_ship_dt) <= 0 OR LEN(sls_ship_dt)<>8;

SELECT 
NULLIF(sls_due_dt,0) AS sls_due_dt
FROM Bronze.crm_sales_details
WHERE ISNUMERIC(sls_due_dt) <= 0 OR LEN(sls_due_dt)<>8;

SELECT sls_order_dt, sls_ship_dt, sls_due_dt
FROM Bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;


--sls_sales, sls_quantity, sls_price
SELECT sls_sales, sls_quantity, sls_price
FROM Bronze.crm_sales_details
WHERE sls_sales < 0 OR sls_quantity < 0 OR sls_price < 0 OR sls_sales <> sls_quantity * sls_price OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
ORDER BY sls_sales, sls_quantity, sls_price


--Checking the consistency of values between tables
SELECT cid
FROM bronze.erp_cust_az12
WHERE cid IN (SELECT cst_key FROM bronze.crm_cust_info)

--Checking for sanity in birthdates
SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate>GETDATE() OR bdate<'1926-01-01';
--Checking for consistency in low cardinality columns
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

--Checking for consistency across derived tables
SELECT id
FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM Silver.crm_prd_info);

--Checking for consistency in low cardinality columns
SELECT DISTINCT cat
FROM Bronze.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM Bronze.erp_px_cat_g1v2

SELECT DISTINCT maintenance
FROM Bronze.erp_px_cat_g1v2

--Checking for consistency across tables to be joined
SELECT cid 
FROM Bronze.erp_loc_a101
WHERE cid IN (SELECT cst_key FROM Bronze.crm_cust_info)

--Checking for consistency in low cardinality columns
SELECT DISTINCT cntry
FROM Bronze.erp_loc_a101;
