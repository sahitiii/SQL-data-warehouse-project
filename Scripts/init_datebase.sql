/*
============================
CREATE DATABASE AND SCHEMAS
============================
Purpose of Script:
This script creates a new database 'datawarehouse' after checking if it already exists.
If the database already exists, it is dropped and recreated.
Additionally, this script sets up three schemas: Bronze, Silver, Gold.

Warning:
Running this script will drop the database 'datawarehouse' entirely if it exsists.
All the data in the database is permenantly deleted.
Proceed with caution and ensure proper backups before running this script*/

USE master;
GO

--DROP AND RECREATE THE DATABASE 'DATAWAREHOUSE'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name='datawarehouse')
  BEGIN
    ALTER DATABASE datawarehouse SET single_user WITH ROLLBACK IMMEDIATE;
    DROP DATABASE datawarehouse
  END;

--CREATE DATABASE DATAWAREHOUSE    
CREATE DATABASE datawarehouse;
GO 
  
USE datawarehouse;
GO

--CREATE SCHEMAS
CREATE SCHEMA Brozen;
GO
  
CREATE SCHEMA Silver;
GO
  
CREATE SCHEMA Gold;
