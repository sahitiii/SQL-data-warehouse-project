CREATE OR ALTER PROCEDURE Silver.silver_load AS
BEGIN
    DECLARE @start_time DATETIME,@end_time DATETIME, @layer_start DATETIME, @layer_end DATETIME
    BEGIN TRY
        PRINT '====================='
        PRINT 'LOADING SILVER LAYER'
        PRINT '====================='
        --Inserting values into the silver.crm_cust_info table from bronze.crm_cust_info table after performing data quality checks and standardization.
        PRINT '>>Truncating crm_cust_info table'
        TRUNCATE TABLE silver.crm_cust_info

        PRINT 'Inserting crm_cust_info table'
        SET @start_time = GETDATE()
        SET @layer_start=GETDATE()
        INSERT INTO silver.crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_material_status,
            cst_gndr,
            cst_create_date
        )
        SELECT 
        cst_id,
        cst_key,
        --Removing unwanted spaces and standardizing the values in the columns
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        --Standardizing the values in the columns for readability and consistency.
        CASE WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married' WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single' ELSE 'Unknown' END AS cst_material_status,
        CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female' ELSE 'Unknown' END AS cst_gndr,
        cst_create_date
        FROM (
            SELECT *,
            ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) AS ranked
        WHERE flag =1;
        SET @end_time=GETDATE()
        PRINT('>>TIME TAKEN TO LOAD crm_cust_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS') 
        PRINT '------------------------------'
        PRINT 'crm_cust_info LOADED SUCESSFULLY'
        PRINT '------------------------------'

        -- Inserting clean data from bronze.crm_prod_info into Silver
        PRINT '>>Truncating crm_prd_info table'
        TRUNCATE TABLE Silver.crm_prd_info;
        PRINT '>>Inserting values into crm_prd_info table'
        SET @start_time = GETDATE()
        INSERT INTO Silver.crm_prd_info(
            prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt
        )
        SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
        SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
        prd_nm,
        COALESCE(prd_cost,0) AS prd_cost,
        CASE UPPER(TRIM(prd_line)) 
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Sports'
        WHEN 'T' THEN 'Touring'
        ELSE 'other'
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(DATEADD(day,-1,LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS DATE) AS prd_end_dt
        FROM bronze.crm_prd_info;
        SET @end_time=GETDATE()
        PRINT('>>TIME TAKEN TO LOAD crm_prd_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS') 
        PRINT '------------------------------'
        PRINT 'crm_prd_info LOADED SUCESSFULLY'
        PRINT '------------------------------'



        --Inserting clean values from bronze.crm_sales_details into Silver
        PRINT '>>Truncating crm_sales_details table'
        TRUNCATE TABLE Silver.crm_sales_details;
        PRINT '>>Inserting values into crm_sales_details'
        SET @start_time= GETDATE()
        INSERT INTO Silver.crm_sales_details(
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_price,
            sls_quantity
        )
        SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt =0 OR LEN(sls_order_dt)<>8 THEN NULL 
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
        END AS sls_order_dt,
        CASE WHEN sls_ship_dt =0 OR LEN(sls_ship_dt)<>8 THEN NULL 
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) 
        END AS sls_ship_dt,
        CASE WHEN sls_due_dt =0 OR LEN(sls_due_dt)<>8 THEN NULL 
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) 
        END AS sls_due_dt,
        CASE WHEN sls_sales < 0 OR sls_sales IS NULL OR sls_sales<> sls_quantity*ABS(sls_price)
        THEN sls_quantity*ABS(sls_price)
        ELSE sls_sales END AS 
        sls_sales,

        CASE WHEN sls_price IS NULL OR sls_price<0 OR sls_price <> (ABS(sls_sales)/NULLIF(sls_quantity,0)) THEN ABS(sls_sales)/sls_quantity
        ELSE sls_price
        END AS sls_price, 

        CASE WHEN sls_quantity IS NULL OR sls_quantity<0 OR sls_quantity <> (ABS(sls_sales)/ABS(sls_price)) THEN ABS(sls_sales)/ABS(sls_price)
        ELSE sls_quantity
        END AS sls_quantity

        FROM bronze.crm_sales_details;
        SET @end_time=GETDATE()
        PRINT('>>TIME TAKEN TO LOAD crm_sales_details: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS') 
        PRINT '-------------------------------------'
        PRINT 'crm_sales_details LOADED SUCESSFULLY'
        PRINT '-------------------------------------'



        --Inserting Clean values into Silver Layer from Bronze
        PRINT '>>Truncating erp_cust_az12 table'
        TRUNCATE TABLE Silver.erp_cust_az12;
        PRINT '>>Inserting  values into erp_cust_az12 table'
        SET @start_time = GETDATE()
        INSERT INTO Silver.erp_cust_az12
        (
            cid,
            bdate,
            gen
        )
        SELECT 
        CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) 
                ELSE cid
                END AS cid,
        CASE 
                WHEN bdate>GETDATE() THEN NULL
                ELSE bdate
                END AS bdate,
        CASE 
                WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(gen), CHAR(160), ''), CHAR(9), ''), CHAR(13), '')) 
                        IN ('FEMALE', 'F') THEN 'Female'
                WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(gen), CHAR(160), ''), CHAR(9), ''), CHAR(13), '')) 
                        IN ('MALE', 'M') THEN 'Male'
                ELSE 'Unknown'
                END AS gen
        FROM Bronze.erp_cust_az12;
        SET @end_time=GETDATE()
        PRINT('>>TIME TAKEN TO LOAD erp_cust_az12: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS') 
        PRINT '-------------------------------------'
        PRINT 'erp_cust_az12 LOADED SUCESSFULLY'
        PRINT '-------------------------------------'



        --Inserting Clean data into Silver Layer from Bronze
        PRINT '>>Truncating erp_loc_a101 table'
        TRUNCATE TABLE Silver.erp_loc_a101;
        PRINT '>>Inserting values into erp_loc_a101'
        SET @start_time = GETDATE()
        INSERT INTO Silver.erp_loc_a101
        (
            cid,
            cntry
        )
        SELECT 
        REPLACE(cid,'-','') AS cid,
        CASE
                    WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(cntry), CHAR(160), ''), CHAR(9), ''), CHAR(13), '')) 
                        IN ('US', 'USA', 'UNITED STATES') THEN 'United States'
                    WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(cntry), CHAR(160), ''), CHAR(9), ''), CHAR(13), '')) 
                        IN ('UK', 'UNITED KINGDOM') THEN 'United Kingdom'
                    WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(cntry), CHAR(160), ''), CHAR(9), ''), CHAR(13), '')) 
                        IN ('DE', 'GERMANY') THEN 'Germany'
                    WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(cntry), CHAR(160), ''), CHAR(9), ''), CHAR(13), '')) 
                        IN ('CA', 'CANADA') THEN 'Canada'
                    WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(cntry), CHAR(160), ''), CHAR(9), ''), CHAR(13), '')) 
                        IN ('AU', 'AUSTRALIA') THEN 'Australia'
                    WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(cntry), CHAR(160), ''), CHAR(9), ''), CHAR(13), '')) 
                        IN ('FR', 'FRANCE') THEN 'France'
                    WHEN REPLACE(REPLACE(REPLACE(TRIM(cntry), CHAR(160), ''), CHAR(9), ''), CHAR(13), '') = '' 
                        THEN NULL
                    ELSE 'Unknown'
                END AS cntry
        FROM Bronze.erp_loc_a101;
        SET @end_time=GETDATE()
        PRINT('>>TIME TAKEN TO LOAD erp_loc_a101: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS') 
        PRINT '-------------------------------------'
        PRINT 'erp_loc_a101 LOADED SUCESSFULLY'
        PRINT '-------------------------------------'


        --Inserting values from Bronze layer into Silver layer
        PRINT 'Truncating erp_px_cat_g1v2'
        TRUNCATE TABLE Silver.erp_px_cat_g1v2;
        PRINT 'Inserting values into erp_px_cat_g1v2 table'
        SET @start_time=GETDATE()
        INSERT INTO Silver.erp_px_cat_g1v2(
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
        id,
        cat,
        subcat,
        CASE WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(maintenance),CHAR(160),''),CHAR(9),''),CHAR(13),'')) = 'Yes' THEN 'Yes'
        WHEN UPPER(REPLACE(REPLACE(REPLACE(TRIM(maintenance),CHAR(160),''),CHAR(9),''),CHAR(13),'')) = 'No' THEN 'No'
        END AS maintenance
        FROM Bronze.erp_px_cat_g1v2
        SET @end_time=GETDATE()
        PRINT('>>TIME TAKEN TO LOAD erp_px_cat_g1v2: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS') 
        PRINT '-------------------------------------'
        PRINT 'erp_px_cat_g1v2 LOADED SUCESSFULLY'
        PRINT '-------------------------------------'
        SET @layer_end=GETDATE()
        PRINT('>>TIME TAKEN TO LOAD Silver Layer: ' + CAST(DATEDIFF(SECOND, @layer_start, @layer_end) AS NVARCHAR(50)) + ' SECONDS') 
        PRINT '================================'
        PRINT 'Silver Layer LOADED SUCESSFULLY'
        PRINT '================================'
    END TRY
    BEGIN CATCH
        PRINT '================================================='
        PRINT 'ERROR OCCURRED WHILE LOADING SILVER LAYER TABLES' 
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE()
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50))
        PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(50))
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR(50))
        PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR(50))
        PRINT '================================================='
    END CATCH
END
GO
