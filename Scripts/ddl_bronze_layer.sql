/* 
==========================================
DDL Script to create Bronze tables
==========================================
Purpose of script:
This script checks in bronze schema, dropping tables if they already exist.
Run the script to redefine the DDL structure of bronze layer*/

IF OBJECT_ID('Bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE Bronze.crm_cust_info;

CREATE TABLE Bronze.crm_cust_info(
    cst_id INT, 
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_material_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

IF OBJECT_ID('Bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE Bronze.crm_prd_info;

CREATE TABLE Bronze.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    pred_end_dt DATE
);

IF OBJECT_ID('Bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE Bronze.crm_sales_details;

CREATE TABLE Bronze.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

IF OBJECT_ID('Bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE Bronze.erp_cust_az12;

CREATE TABLE Bronze.erp_cust_az12(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50),
);

IF OBJECT_ID('Bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE Bronze.erp_loc_a101;

CREATE TABLE Bronze.erp_loc_a101(
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

IF OBJECT_ID('Bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE Bronze.erp_px_cat_g1v2;

CREATE TABLE Bronze.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME,@end_time DATETIME, @layer_start DATETIME, @layer_end DATETIME
BEGIN TRY
    PRINT '------------------------------'
    PRINT 'LOADING BRONZE LAYER TABLES...'
    PRINT '------------------------------'
        SET @layer_start= GETDATE()
        SET @start_time = GETDATE()
        PRINT '>>TRUNCATING AND LOADING BRONZE.CRM_CUST_INFO'
            TRUNCATE TABLE Bronze.crm_cust_info;

            BULK INSERT Bronze.crm_cust_info
            FROM '/var/opt/mssql/data/cust_info.csv'
            WITH (
                FIRSTROW=2,
                FIELDTERMINATOR=',',
                TABLOCK
                );
        SET @end_time = GETDATE()
        PRINT('>>TIME TAKEN TO LOAD CRM_CUST_INFO: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS')
    PRINT '------------------------------'
    PRINT 'CRM_CUST_INFO LOADED SUCESSFULLY'
    PRINT '------------------------------'
        SET @start_time = GETDATE()

        PRINT '>>TRUNCATING AND LOADING BRONZE.CRM_PRD_INFO'
            TRUNCATE TABLE Bronze.crm_prd_info;

            BULK INSERT Bronze.crm_prd_info
            FROM '/var/opt/mssql/data/prd_info.csv'
            WITH (
                FIRSTROW=2,
                FIELDTERMINATOR=',',
                TABLOCK
                );
        SET @end_time = GETDATE()
        PRINT('>>TIME TAKEN TO LOAD CRM_PRD_INFO: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS')
    PRINT '------------------------------'
    PRINT 'CRM_PRD_INFO LOADED SUCESSFULLY'
    PRINT '------------------------------'
        SET @start_time = GETDATE()
            PRINT '>>TRUNCATING AND LOADING BRONZE.CRM_SALES_DETAILS'
            TRUNCATE TABLE Bronze.crm_sales_details;

            BULK INSERT Bronze.crm_sales_details
            FROM '/var/opt/mssql/data/sales_details.csv'
            WITH (
                FIRSTROW=2,
                FIELDTERMINATOR=',',
                TABLOCK
                );
        SET @end_time = GETDATE()
        PRINT('>>TIME TAKEN TO LOAD CRM_SALES_DETAILS: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS')
    PRINT '------------------------------'
    PRINT 'CRM_SALES_DETAILS LOADED SUCESSFULLY'
    PRINT '------------------------------'
        SET @start_time = GETDATE() 
            PRINT '>>TRUNCATING AND LOADING BRONZE.ERP_CUST_AZ12'
            TRUNCATE TABLE Bronze.erp_cust_az12;

            BULK INSERT Bronze.erp_cust_az12
            FROM '/var/opt/mssql/data/cust_az12.csv'
            WITH (
                FIRSTROW=2,
                FIELDTERMINATOR=',',
                TABLOCK
                );
        SET @end_time = GETDATE()
        PRINT('>>TIME TAKEN TO LOAD ERP_CUST_AZ12: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS') 
    PRINT '------------------------------'
    PRINT 'ERP_CUST_AZ12 LOADED SUCESSFULLY'
    PRINT '------------------------------'
        SET @start_time = GETDATE()
            PRINT '>>TRUNCATING AND LOADING BRONZE.ERP_LOC_A101'
            TRUNCATE TABLE Bronze.erp_loc_a101;

            BULK INSERT Bronze.erp_loc_a101
            FROM '/var/opt/mssql/data/loc_a101.csv'
            WITH (
                FIRSTROW=2,
                FIELDTERMINATOR=',',
                TABLOCK
                );
        SET @end_time = GETDATE()
        PRINT('>>TIME TAKEN TO LOAD ERP_LOC_A101: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS') 
    PRINT '------------------------------'
    PRINT 'ERP_LOC_A101 LOADED SUCESSFULLY'
    PRINT '------------------------------'
        SET @start_time = GETDATE()
            PRINT '>>TRUNCATING AND LOADING BRONZE.ERP_PX_CAT_G1V2'
            TRUNCATE TABLE Bronze.erp_px_cat_g1v2;

            BULK INSERT Bronze.erp_px_cat_g1v2
            FROM '/var/opt/mssql/data/px_cat_g1v2.csv'
            WITH (
                FIRSTROW=2,
                FIELDTERMINATOR=',',
                TABLOCK
                );
        SET @end_time = GETDATE()
        PRINT('>>TIME TAKEN TO LOAD ERP_PX_CAT_G1V2: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(50)) + ' SECONDS')
    PRINT '----------------------------------'
    PRINT 'ERP_PX_CAT_G1V2 LOADED SUCESSFULLY'
    PRINT '----------------------------------'  
    SET @layer_end = GETDATE()
    PRINT('>>TOTAL TIME TAKEN TO LOAD BRONZE LAYER: ' + CAST(DATEDIFF(SECOND, @layer_start, @layer_end) AS NVARCHAR(50)) + ' SECONDS')
END TRY
BEGIN CATCH
    PRINT '================================================='
    PRINT 'ERROR OCCURRED WHILE LOADING BRONZE LAYER TABLES' 
    PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE()
    PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR(50))
    PRINT 'ERROR SEVERITY: ' + CAST(ERROR_SEVERITY() AS NVARCHAR(50))
    PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR(50))
    PRINT 'ERROR LINE: ' + CAST(ERROR_LINE() AS NVARCHAR(50))
    PRINT '================================================='
END CATCH
END
