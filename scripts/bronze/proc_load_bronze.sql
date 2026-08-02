CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN 
	DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY 
	PRINT'=========================================================================================='
	PRINT'LODING BRONZE LAYER '
	PRINT'=========================================================================================='
	SET @batch_start_time = GETDATE();
	PRINT'------------------------------------------------------------------------------------------'
	PRINT'LODING CRM  '
	PRINT'------------------------------------------------------------------------------------------'
	
		SET @start_time = GETDATE();
		PRINT'Truncating  table: bronze.crm_cust_info '
		TRUNCATE TABLE bronze.crm_cust_info ;
		BULK INSERT bronze.crm_cust_info 
		FROM 'C:\Users\mehar\Downloads\SQL-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>Load duration:'+ CAST(DATEDIFF(SECOND, @start_time,@end_time)AS NVARCHAR)+ 'seconds';
		PRINT'---------------------------'

		PRINT'Truncating  table: bronze.crm_prd_info '

		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.crm_prd_info;
		BULK INSERT bronze.crm_prd_info 
		FROM 'C:\Users\mehar\Downloads\SQL-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>Load duration:'+ CAST(DATEDIFF(SECOND, @start_time,@end_time)AS NVARCHAR)+ 'seconds';
		PRINT'---------------------------'
		PRINT'Truncating  table: bronze.crm_sales_details '

		TRUNCATE TABLE bronze.crm_sales_details;
		SET @start_time= GETDATE();
		BULK INSERT bronze.crm_sales_details 
		FROM 'C:\Users\mehar\Downloads\SQL-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time = GETDATE();
			PRINT '>>Load duration:'+ CAST(DATEDIFF(SECOND, @start_time,@end_time)AS NVARCHAR)+ 'seconds';
			PRINT'---------------------------'
	PRINT'------------------------------------------------------------------------------------------'
	PRINT'LODING CRM  '
	PRINT'------------------------------------------------------------------------------------------'

	
		PRINT'Truncating  table: bronze.erp_cust_az12 '
		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.erp_cust_az12;
		BULK INSERT bronze.erp_cust_az12 
		FROM 'C:\Users\mehar\Downloads\SQL-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>>Load duration:'+ CAST(DATEDIFF(SECOND, @start_time,@end_time)AS NVARCHAR)+ 'seconds';
		PRINT'---------------------------'
		PRINT'Truncating  table: bronze.erp_loc_a101 '

		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.erp_loc_a101;
		BULK INSERT bronze.erp_loc_a101
		FROM "C:\Users\mehar\Downloads\SQL-data-warehouse-project\datasets\source_erp\LOC_A101.csv"
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
			);
		SET @end_time = GETDATE();
		PRINT '>>Load duration:'+ CAST(DATEDIFF(SECOND, @start_time,@end_time)AS NVARCHAR)+ 'seconds';
		PRINT'---------------------------'
		PRINT'Truncating  table: bronze.erp_px_cat_g1v2 '
		SET @start_time=GETDATE();
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		BULK INSERT bronze.erp_px_cat_g1v2 
		FROM "C:\Users\mehar\Downloads\SQL-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv"
		WITH(
			FIRSTROW=2,
			FIELDTERMINATOR= ',',
			TABLOCK);
		SET @end_time = GETDATE();
		PRINT '>>Load duration:'+ CAST(DATEDIFF(SECOND, @start_time,@end_time)AS NVARCHAR)+ 'seconds';
		PRINT'---------------------------'

		SET @batch_end_time = GETDATE();
		PRINT'Loading Bronze Layer is completed ';
		PRINT '>>Batch Load duration:'+ CAST(DATEDIFF(SECOND, @batch_start_time,@batch_end_time)AS NVARCHAR)+ 'seconds';
		PRINT'---------------------------';
	END TRY
	BEGIN CATCH 
	PRINT'=========================================================================================='
	PRINT'ERROR OCCURED DURING LODING BRONZE LAYER '
	PRINT 'ERROR MESSAGE :'+ERROR_MESSAGE();
	PRINT 'ERROR MESSAGE :'+CAST(ERROR_NUMBER() AS NVARCHAR);
	PRINT'=========================================================================================='
	END CATCH
END;