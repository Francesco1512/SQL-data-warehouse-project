/*
===================================
Crate Database and Schemas
===================================

Script purpose:
	This script craeates a new database namend 'DataWarehouse' after checking if it already exists.
	If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the database: 'bronze', 'silver', 'gold'.

Warning:
	Running the script will drop the entire 'DataWarehouse' database if it exists.
	All data in the database will be permantely deleted. Proceed with caution and ensure you have proper backups before running this script.

*/

USE master;
GO

---Drop and recreate the 'DataWarehouse' database

IF EXISTS ( SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

---Create Database 'Data Warehouse'


CREATE DATABASE DataWarehouse;

USE DataWarehouse;

---Create Schemas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
