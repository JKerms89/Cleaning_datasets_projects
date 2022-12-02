-- Let's first import the messy movies dataset into SQL
-- I do this using the bespoke SQL Server Import and Export Wizard

USE data_cleaning

-- Let's take a look at the table

SELECT *
FROM movies_dirty

exec sp_columns movies_dirty;

-- Let's see how many columns/rows in  the table

SELECT COUNT(*)
FROM movies_dirty;

SELECT COUNT(column_name) as Number 
FROM information_schema.columns
WHERE table_name = 'movies_dirty';

-- We have a table of 9 columns and 9999 rows


-- Lets see which columns have null values
SELECT COUNT(*)-COUNT(movies) As movies, 
COUNT(*)-COUNT([year]) As [year],
COUNT(*)-COUNT([genre]) As [genre],
COUNT(*)-COUNT([one-line]) As [one-line],
COUNT(*)-COUNT([stars]) As [stars],
COUNT(*)-COUNT([runtime]) As [runtime],
COUNT(*)-COUNT([votes]) As [votes],
COUNT(*)-COUNT([gross]) As [gross],
COUNT(*)-COUNT([rating]) As [rating]
FROM movies_dirty;

-- We can see that only 3 columns have non-null values

-- We then need to remove rows where runtime is NULL 

DELETE 
FROM movies_dirty
WHERE runtime IS NULL;

-- Let's check how many rows with null values there are in the runtime column.
-- There should be 0 null values are 7041 non-null values.

SELECT COUNT(runtime) AS [num of non nulls]
, COUNT(*)-COUNT(runtime) AS [runtime_n_nulls]
FROM movies_dirty;

-- Drop null values in the 'genre' column

DELETE 
FROM movies_dirty
WHERE genre IS NULL;

-- Let's check how many rows with null values there are in the genre column.
-- There should be 0 null values are 7032 non-null values.

SELECT COUNT(genre) AS [num of non nulls]
, COUNT(*)-COUNT(genre) AS [runtime_n_nulls]
FROM movies_dirty;

-- drop null values in YEAR column

DELETE 
FROM movies_dirty
WHERE year IS NULL;

SELECT COUNT(year) AS [num of non nulls]
, COUNT(*)-COUNT(year) AS [runtime_n_nulls]
FROM movies_dirty;

-- Let's check how many rows with null values there are in the genre column.
-- There should be 0 null values are 7005 non-null values.
-- Now we have proper data entries, so we should fill null value with some value in columns
--that its data not recorded because it's not appear due to people not recommend/rate(RATING and VOTES , not sold(Gross).

-- fill some null values with predefined values in the rating, votes, gross columns

UPDATE movies_dirty
SET gross = '$0.0M'
WHERE gross IS NULL 

UPDATE movies_dirty
SET rating = '0.0'
WHERE rating IS NULL 

UPDATE movies_dirty
SET votes = '0'
WHERE votes IS NULL 

-- Lets see the updated results
SELECT gross, rating, votes
FROM movies_dirty;

-- Lets take a look again at the altered table 
SELECT *
FROM movies_dirty

-- Now we really need to clean the string values in the YEAR column
-- The first thing to note is that some of the values start with (-) which should be removed


SELECT SUBSTRING(YEAR,2,len(YEAR))
		FROM  movies_dirty
		WHERE YEAR LIKE '-%'

-- First, let's update year column without (-) character at the beginning of a string

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '-%' THEN 
REPLACE(YEAR,'-','') ELSE YEAR END 

-- Let's update year column to replace '–' with (-)

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '%–%' THEN 
REPLACE(YEAR,'–','-') ELSE YEAR END 

SELECT *
FROM movies_dirty

-- Let's update year column to replace '(I)' with ''

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '%(II)%' THEN 
REPLACE(YEAR,'(I)','') ELSE YEAR END 

SELECT *
FROM movies_dirty


-- Let's update year column to replace '(II)' with ''

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '%(II)%' THEN 
REPLACE(YEAR,'(II)','') ELSE YEAR END 

SELECT *
FROM movies_dirty

-- Remove open parenthesis (

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '(%' THEN 
REPLACE(YEAR,'(','') ELSE YEAR END 

SELECT *
FROM movies_dirty

-- Remove closed parenthesis

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '%)' THEN 
REPLACE(YEAR,')','') ELSE YEAR END 

SELECT *
FROM movies_dirty

-- Add 'ongoing' if str ends with '-'

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '%- ' THEN 
REPLACE(YEAR,'- ','-ongoing') ELSE YEAR END 

SELECT *
FROM movies_dirty

-- Remove whitespace from year column

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE ' %' THEN 
REPLACE(YEAR,' ','') ELSE YEAR END 

SELECT *
FROM movies_dirty


-- Remove III from year column
UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '%III%' THEN 
REPLACE(YEAR,'III','') ELSE YEAR END 

SELECT *
FROM movies_dirty

-- Add spaces to make year column more readable

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '%-%' THEN 
REPLACE(YEAR,'-',' - ') ELSE YEAR END 

SELECT *
FROM movies_dirty

-- See how many rows contain strings containing 'TV' substring

SELECT DISTINCT YEAR
FROM movies_dirty
WHERE year LIKE '%TV%'


-- REMOVE 'TV original/short/special' substrings from the year column

UPDATE movies_dirty
SET YEAR = 
CASE 
WHEN YEAR LIKE '%TV Special%' THEN 
REPLACE(YEAR,'TV Special','') 
WHEN YEAR LIKE '%TV Movie%' THEN 
REPLACE(YEAR,'TV Movie','') 
WHEN YEAR LIKE '%TV Short%' THEN 
REPLACE(YEAR,'TV Short','') 
ELSE YEAR END;

SELECT *
FROM movies_dirty

-- See how many rows contain strings containing 'video' substring

SELECT DISTINCT YEAR
FROM movies_dirty
WHERE year LIKE '%Video%'

-- REMOVE 'video' substring from year column

UPDATE movies_dirty
SET YEAR = 
CASE WHEN YEAR LIKE '%Video%' THEN 
REPLACE(YEAR,'Video','') ELSE YEAR END;

SELECT *
FROM movies_dirty

-- Remove whitespace at beginning and end of string in stars column

UPDATE movies_dirty
SET STARS = 
CASE WHEN STARS LIKE '% %' THEN
REPLACE(LTRIM(RTRIM(STARS)),' ', '') ELSE STARS END;

SELECT *
FROM movies_dirty

-- Remove whitespace at beginning and end of string in MOVIES column

UPDATE movies_dirty
SET MOVIES = 
CASE WHEN MOVIES LIKE '% %' THEN
REPLACE(LTRIM(RTRIM(MOVIES)),' ', '') ELSE MOVIES END;

SELECT *
FROM movies_dirty




-- Add another column called 'DIRECTOR(S)' from 'STARS' column
ALTER TABLE movies_dirty
ADD DIRECTOR_updated VARCHAR(500);

SELECT *
FROM movies_dirty

-- Update new column
UPDATE movies_dirty
SET DIRECTOR_updated = 
	CASE WHEN STARS LIKE '%Director%' THEN
	SUBSTRING(STARS, 1, CHARINDEX('|', STARS))
	ELSE 'Unspecified' END 
FROM movies_dirty


-- Update STARS COLUMN to contain only string from '|' onwards

UPDATE movies_dirty
SET STARS = 
  SUBSTRING(STARS, CHARINDEX('|', STARS), LEN(STARS) - CHARINDEX('|', STARS) + 1) 
SELECT *
FROM movies_dirty

-- Remove | from Stars and Director columns

UPDATE movies_dirty
SET Director_updated = 
CASE WHEN Director_updated  LIKE '%|%' THEN 
REPLACE(Director_updated ,'|','') ELSE Director_updated END 

SELECT *
FROM movies_dirty


UPDATE movies_dirty
SET Stars = 
CASE WHEN Stars  LIKE '%|%' THEN 
REPLACE(Stars,'|','') ELSE Stars END 

SELECT *
FROM movies_dirty

-- Data is definitely much cleaner now.
-- The next step is to change datatype of rating to a FLOAT, VOTES to an INT, Runtime to INT and GROSS to INT so we can carry out some summary statistics on the movies dataset.