
-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
	select 
	ROW_NUMBER() OVER(ORDER BY ci.cst_id)as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	el.cntry as country,
	ci.cst_marital_status as marital_status ,
	CASE WHEN ci.cst_gndr!= 'N/A' THEN ci.cst_gndr
		ELSE COALESCE(ec.gen,'N/A' )
		end as gender,
	ec.bdate as birth_date,
	ci.dwh_create_date as create_date
	from silver.crm_cust_info ci
	left join silver.erp_cust_az12 ec
	on ci.cst_key=ec.cid
	left join silver.erp_loc_a101 el 
	on ci.cst_key=el.cid;
go
-- =============================================================================
-- Create Dimension: gold.dim_product
-- =============================================================================

IF OBJECT_ID('gold.dim_product', 'V') IS NOT NULL
    DROP VIEW gold.dim_product;
GO
CREATE VIEW  gold.dim_product AS
select 
	ROW_NUMBER() OVER(ORDER BY cp.prd_start_dt,cp.prd_key) as product_key,
	cp.prd_id as product_id,
	cp.prd_key as product_number ,
	cp.prd_nm as product_name,
	cp.cat_id as category_id,
	pc.cat as category ,
	pc.subcat as subcategory,
	pc.maintainance,
	cp.prd_cost  as cost,
	cp.prd_line as product_line ,
	cp.prd_start_dt as start_date

from silver.crm_prd_info cp
left join silver.erp_px_cat_g1v2 pc
on cp.cat_id=pc.id
where cp.prd_end_dt is null
go
-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
select 
sd.sls_ord_num as order_number,
pr.product_key,
dc.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as shipping_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from silver.crm_sales_details sd
left join gold.dim_product pr 
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers dc
on sd.sls_cust_id=dc.customer_id  
