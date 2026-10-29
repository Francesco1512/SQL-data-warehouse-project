/*
====================================================
DDL scripts: create Gold Views
====================================================
Script Purpose: 
	This script creates views for gold layer in 
	the data warehouse. 
	The gold layer represents the final dimensions and 
	facts tables (Star Schema)

	Each views performs transformations and combines 
	data from the silver layer to produce clean, enriched, 
	and business oriented dataset.

Usage: 
	-These views can be queried directly for analytics and reporting

======================================================
*/


-- =================================================
-- Create Dimension: gold.dim_customers
-- =================================================
	
IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers

GO 

CREATE VIEW gold.dim_customers AS

select
	row_number() over (order by cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	ci.cst_marital_status as marital_status,
	CASE
		WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		ELSE COALESCE( ca.gen, 'n/a')
	END AS gender,
	ca.bdate as birthdate,
	ci.cst_create_date as create_date
from 
silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON		ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON		ci.cst_key = la.cid

-- =================================================
-- Create Dimension: gold.dim_products
-- =================================================
	
IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products

GO 

CREATE VIEW gold.dim_products AS 
select 
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	px.cat as category,
	px.subcat as subcategory,	
	px.maintenance,
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_dt as start_date	
	from
	silver.crm_prd_info pn
	LEFT JOIN silver.erp_px_cat_g1v2 px
	ON        pn.cat_id = px.id
	where pn.prd_end_dt is null   --filtering out historicals datas

-- =================================================
-- Create Fact: gold.fact_sales
-- =================================================
	
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales

GO 

CREATE VIEW gold.fact_sales AS
select 
sd.sls_ord_num as order_number,
pr.product_key,
cu.customer_key,
sd.sls_order_dt as order_date,
sd.sls_ship_dt as ship_date,
sd.sls_due_dt as due_date,
sd.sls_sales as sales_amount,
sd.sls_quantity as quantity,
sd.sls_price as price
from 
silver.crm_sales_details sd
LEFT JOIN gold.dimension_product pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id 
