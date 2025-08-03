-- DATA CLEANING

SELECT *
FROM layoffs;
-- 2361 rows returned

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Fill NULL values or Blank values
-- 4. Remove any columns not useful

-- you create the table and then you insert the data from the raw table layoffs
-- WARNING: do not work on the original raw table layoffs, it is NOT best practice
CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;
-- 2361 rows returned
INSERT layoffs_staging
SELECT * 
FROM layoffs;
SELECT *
FROM layoffs_staging;
-- 2361 rows returned


-- SPOT DUPLICATES
WITH duplicate_cte AS 
(
SELECT * ,
ROW_NUMBER() OVER (
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) as row_num
FROM layoffs_staging
)

-- select all the dupliate rows by calling the row_num column filtered for >1
SELECT *
FROM duplicate_cte
WHERE row_num > 1; -- 22 rows returned

-- point checks of several duplicate rows by calling individual rows filtered by a company name that appeared in the duplicates 
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- try to delete the duplicates from the cte created
WITH duplicate_cte AS 
(
SELECT * ,
ROW_NUMBER() OVER (
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) as row_num
FROM layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;

DELETE 
FROM duplicate_cte
WHERE row_num > 1; -- "Table duplicate_cte doesn't exist" while it exists actually as a CTE, not a TEMP TABLE

SELECT *
FROM duplicate_cte
WHERE row_num > 1;
-- you can NOT UPDATE a CTE with update statement like DELETE doesn't work on CTEs
-- you need to create a copy of the raw table as a staging table that you're going to work on

-- REMOVE DUPLICATES from this DATABASE TABLE layoffs (RAW DATA)
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2; -- 0 rows returned 

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER (
partition by company, location, industry, total_laid_off, percentage_laid_off, 'date', stage, country, funds_raised_millions
) as row_num
FROM layoffs_staging
;
ROW_NUMBER

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
; -- 22 rows duplicates
DELETE
FROM layoffs_staging2
WHERE row_num > 1
;
SELECT *
FROM layoffs_staging2
;
-- 2339 rows returned from the staging2 table

-- STANDARDIZE THE DATA
SELECT company, TRIM(company)
FROM layoffs_staging2; -- TRIM OUT the white blanks around the name

UPDATE layoffs_staging2
SET company=TRIM(company)
;

-- Exploratory Data Analysis of columns what we need to fix standardize depending in each country
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1
;
SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'
;
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'
; -- updated like 3 rows now it's all crypto

SELECT DISTINCT Country, TRIM(TRAILING'.' FROM country)
FROM layoffs_staging2
ORDER BY 1
; -- TRIM points at the end of words "United States."
UPDATE layoffs_staging2
SET Country = TRIM(TRAILING'.' FROM country)
WHERE country LIKE 'United States%' 
;
SELECT DISTINCT Country, TRIM(TRAILING'.' FROM country)
FROM layoffs_staging2
ORDER BY 1
;

-- format DATE as a DATE and not as TEXT for TIME SERIES analysis
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2
ORDER BY 1
;
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE
; -- change the column format to a date as well


-- REMOVE BLANK OR NULL VALUES --
-- Exploratory Data Analysis in different columns of the table with NULLS
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
;
SELECT *
FROM layoffs_staging2
WHERE industry = NULL OR industry = ''
;
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'
;
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ''
;

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL 
;
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 	-- didn't work with '' WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL -- beware!!! its t2 industry
;


-- DELETE any columns or rows NOT USEFUL DATA
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL
; -- 348 rows deleted with NULLS
SELECT *
FROM layoffs_staging2
; -- the goal later will be to analyze on percentage laid off or number raw laid off
-- 1991 rows remaining returned
ALTER TABLE layoffs_staging2
DROP COLUMN row_num
;

