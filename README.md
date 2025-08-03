# Data Cleaning & EAD with SQL
My Portfolio Project using SQL for - Data Cleaning &amp; Exploratory Data Analysis - on an open dataset: layoffs in the world in 2022-2023.  
Welcome to the Data Cleaning with SQL project! This repository demonstrates best practices and techniques for cleaning, transforming, and preparing raw data for analysis using SQL. It is suitable for analysts, data engineers, and anyone interested in learning systematic data cleaning methods leveraging the power of relational databases.

## Project Overview

Data cleaning is a crucial step in any data pipeline. This project showcases how SQL can be used to:
- Identify and handle NULL values, missing or inconsistent data
- Remove duplicates
- Standardize data and formats (e.g., dates, strings)
- Detect and resolve outliers
- Prepare data for further analysis or reporting

## Features

- **SQL Scripts**:  
UPDATE layoffs_staging2 t1  
JOIN layoffs_staging2 t2  
	  ON t1.company = t2.company  
    AND t1.location = t2.location  
SET t1.industry = t2.industry  
WHERE t1.industry IS NULL  
AND t2.industry IS NOT NULL;    

- **Sample Data**:  
  ' Casper' company TRIM to 'Casper'  
  'United States.' country CHANGE to 'United States'  
  'Cryptocurrency' industry standardize to 'Crypto'  
- **Documentation**:
1. Removing duplicate was made using an extra flagging column created with ROW_NUMBER OVER ( PARTITION BY raw columns)
2. Standardize data values using UPDATE table SET column = TRIM(column) or other FUNCTION(column)
3. Remove NULL or BLANK VALUES with UPDATE table JOIN on itself SET t1.column = t2.column WHERE t1.column IS NULL AND t2.column IS NOT NULL
4. REMOVE NOT USEFUL columns or rows using DELETE rows or ALTER TABLE table DROP COLUMN row_num
  
- **Best Practices**:
1. Always create a STAGING table, aka a copy of the raw table you can work on
2. Always SELECT before and after DELETE and UPDATE commands
3. Run the sql scripts one script at a time to see the output in the Result Window

## Getting Started

### Prerequisites

- Any SQL-compatible database (PostgreSQL, MySQL, SQL Server, SQLite, etc.)
- Basic knowledge of MySQL syntax: the project was written in MySQL language under MySQL Workbench platform from Oracle

### Setup

1. Clone this repository:
    ```bash
    git clone (https://github.com/antoniguedes/SQL-Data-Cleaning-EDA-Project)
    ```
2. Load the sample dataset into your database using the provided world layoffs raw 2022-2023.csv file
3. Run the cleaning scripts found in the SQL file, in the recommended order first Data Cleaning.sql, then EDA.sql .

## Example Workflow

1. **Load Raw Data**
2. **Remove Duplicates**
3. **Handle Missing Values**
4. **Standardize Data Formats**
5. **Validate and Correct Data Types**
7. **Export Cleaned Data**

Each step is documented with sample SQL queries and explanations.
