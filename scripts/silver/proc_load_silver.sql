CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
    BEGIN TRY

SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		-- Loading silver.crm_cust_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
PRINT '>> Inserting Data Into: silver.crm_cust_info';
INSERT INTO silver.crm_cust_info
	(cst_id,
	cst_key,
	cst_firstname,
	cst_lastname,
	cst_marital_status,
	cst_gndr,
	cst_create_date
	) 
		SELECT 
			cst_id,
			cst_key,
			trim(cst_firstname) as cst_firstname,
			trim(cst_lastname) as cst_lastname,
			case when UPPER(TRIM(cst_marital_status))='M' then 'Married' 
				when UPPER(TRIM(cst_marital_status))='S' then 'Single' 
				else 'N/A'
			end as cst_marital_status,
			case when UPPER(TRIM(cst_gndr))='M' then 'Male' 
				when UPPER(TRIM(cst_gndr))='F' then 'Female' 
				else 'N/A'
			end as cst_gndr ,
			cst_create_date
			from 
					(Select *, Row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
					from bronze.crm_cust_info
					where cst_id IS NOT NULL) as t
		where flag_last= 1;
SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		-- Loading silver.crm_prd_info
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info';
TRUNCATE TABLE silver.crm_prd_info;
PRINT '>> Inserting Data Into: silver.crm_prd_info';
INSERT INTO silver.crm_prd_info(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt)
select 
	prd_id,
	REPLACE(SUBSTRING(prd_key,1,5),'-','_')as cat_id,
	SUBSTRING(prd_key,7,LEN(prd_key))as prd_key,
	prd_nm,
	ISNULL(prd_cost,0)as prd_cost,
	case		when UPPER(TRIM(prd_line))='M' then 'Mountain' 
				when UPPER(TRIM(prd_line))='R' then 'Road'
				when UPPER(TRIM(prd_line))='S' then 'Other Sales' 
				when UPPER(TRIM(prd_line))='T' then 'Touring' 
				else 'N/A'
	end as prd_line,
	CAST (prd_start_dt AS DATE) AS prd_start_dt,
	CAST (LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt 
from bronze.crm_prd_info
SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

-- Loading silver.crm_sales_details
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details';
TRUNCATE TABLE silver.crm_sales_details;
PRINT '>> Inserting Data Into: silver.crm_sales_details';
INSERT INTO silver.crm_sales_details(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price)
select sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE  WHEN sls_order_dt= 0  OR LEN(sls_order_dt) !=8 THEN NULL 
ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)END AS sls_order_dt,
CASE  WHEN sls_ship_dt= 0  OR LEN(sls_ship_dt) !=8 THEN NULL 
ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE) END AS sls_ship_dt,
CASE  WHEN sls_due_dt= 0  OR LEN(sls_due_dt) !=8 THEN NULL 
ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE) END AS sls_due_dt,

CASE WHEN sls_sales IS NULL OR sls_sales<=0 OR sls_sales != abs(sls_price) * sls_quantity
	THEN abs(sls_price) * sls_quantity
	ELSE sls_sales
	END AS sls_sales,
sls_quantity,
CASE WHEN sls_price IS NULL OR sls_price<=0
	THEN sls_sales /NULLIF( sls_quantity,0) 
	ELSE sls_price
	END AS sls_price
from bronze.crm_sales_details;
SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

-- Loading silver.erp_cust_az12
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
TRUNCATE TABLE silver.erp_cust_az12;
PRINT '>> Inserting Data Into: silver.erp_cust_az12';
INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
SELECT	CASE  WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID)) else cid END AS cid ,
		CASE WHEN bdate >GETDATE() THEN NULL 
			ELSE bdate
		END AS bdate,
		CASE 
			when Upper(trim(GEN)) in ('M','MALE') then 'Male'
			when Upper(trim(GEN)) in ( 'F','FEMALE') then 'Female'
			ELSE 'N/A' 
		END AS gen 
FROM bronze.erp_cust_az12;
SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

-- Loading silver.erp_loc_a101
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';

TRUNCATE TABLE silver.erp_loc_a101;
PRINT '>> Inserting Data Into: silver.erp_loc_a101';
INSERT INTO silver.erp_loc_a101(cid,cntry)
select  REPLACE(cid,'-','') AS cid,
CASE WHEN TRIM(cntry)='DE' THEN 'Germany'
WHEN TRIM(cntry)in ('US','USA') THEN 'United States'
WHEN TRIM(cntry) IS NULL or TRIM(cntry) ='' THEN 'N/A'
else TRIM(cntry) 
End as cntryy 
from bronze.erp_loc_a101;
SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

-- Loading silver.erp_px_cat_g1v2
        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2;
PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
INSERT INTO silver.erp_px_cat_g1v2  (
	id,
	cat,
	subcat,
	maintainance )
select
	id,
	cat,
	subcat,
	maintainance 
	from bronze.erp_px_cat_g1v2;
SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
END TRY
BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END


	
