/*
=====================================================
STORED PROCEDURE: Load Bronze Layer( Source -> Bronze)
=====================================================
Purpose of the script:
This script loads the data into 'bronze' schema from external CSV files.
It truncates the full table before loading, and uses BULK INSERT to load the data into bronze tables.

Parameters:
None, this store procedure doesn't accept any parameters or return any values.

Usage example:
EXEC bronze.load_bronze;
*/

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
    PRINT '---------------------------------'
    PRINT 'CRM_PRD_INFO LOADED SUCESSFULLY'
    PRINT '---------------------------------'
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
