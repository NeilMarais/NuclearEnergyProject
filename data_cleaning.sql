-- 4 STEPS FOR DATA CLEANING --
# 1. Remove duplicates
# 2. Standardise the data
# 3. Handle NULL or blank values
# 4. Remove any unnecessary columns or rows.

# Create a backup of the raw data
CREATE TABLE reactors_parent_companies_raw
LIKE reactors_parent_companies;

INSERT reactors_parent_companies_raw
SELECT*
FROM reactors_parent_companies;

SELECT*
FROM reactors_parent_companies_raw;

CREATE TABLE us_nuclear_generation_raw 
LIKE us_nuclear_generation;
INSERT us_nuclear_generation_raw 
SELECT*
FROM us_nuclear_generation;

CREATE TABLE world_nuclear_energy_generation_raw
LIKE world_nuclear_energy_generation;
INSERT world_nuclear_energy_generation_raw
SELECT*
FROM world_nuclear_energy_generation;

-- 1. Check each table for duplicates and delete them --
SELECT*
FROM(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY
	`Plant Name, Unit Number`,`Plant Name, Unit Number`,`Parent Company Website`, `Year of Update`
	) AS 'row_number'
    FROM reactors_parent_companies
) AS table_rows
WHERE `row_number` !=1;

# NO DUPLICATES FOUND

-- Repeat the process for the other tables --
SELECT*
FROM(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY
	`YEAR`, `Total Electricity Generation`, `Nuclear Generation`, `NUCLEAR FUEL SHARE`, `CAPACITY FACTOR`, `SUMMER CAPACITY`
	) AS 'row_number'
    FROM us_nuclear_generation
) AS table_rows
WHERE `row_number` !=1;

# NO DUPLICATES FOUND

SELECT*
FROM(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY
	`Year`, `Month`
	) AS 'row_number'
    FROM world_electricity_generation
) AS table_rows
WHERE `row_number` !=1;

# NO DUPLICATES FOUND

SELECT*
FROM(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY
	Entity, `Year`
	) AS 'row_number'
    FROM world_nuclear_energy_generation
) AS table_rows
WHERE `row_number` !=1;

# NO DUPLICATES FOUND
# So, there were no duplicate entries in any of our tables.

-- 2. Standardising the Data -- 

# I want to standardise the data across all the tables so that power is always measured in terrawatts
CREATE TABLE us_nuclear_generation1
LIKE us_nuclear_generation_raw;
INSERT us_nuclear_generation1 
SELECT*
FROM us_nuclear_generation_raw;

ALTER TABLE us_nuclear_generation1
MODIFY COLUMN `Nuclear Generation` DOUBLE;

ALTER TABLE us_nuclear_generation1
MODIFY COLUMN `Summer Capacity` DOUBLE;

ALTER TABLE us_nuclear_generation1
MODIFY COLUMN `Total Electricity Generation` DOUBLE;

UPDATE us_nuclear_generation1
SET `Nuclear Generation` = `Nuclear Generation`/1000000;

UPDATE us_nuclear_generation1
SET `Summer Capacity` = `Summer Capacity`/1000000;

UPDATE us_nuclear_generation1
SET `Total Electricity Generation` = `Total Electricity Generation`/1000000;

# I want to check whether all the country names are correct for the world nuclear data
SELECT DISTINCT Entity
FROM world_nuclear_energy_generation;
# They seem fine so we can move on

-- 3. Null Values --
# The world_nuclear_energy_generation table has many null values so we need to handle these.

SELECT *
FROM world_nuclear_energy_generation 
WHERE share_of_electricity_pct IS NULL AND electricity_from_nuclear_twh = 0;

#For regions which have 0 TWh electricity from nuclear power, we can set the share = 0%.

UPDATE world_nuclear_energy_generation
SET share_of_electricity_pct = 0
WHERE share_of_electricity_pct IS NULL AND electricity_from_nuclear_twh = 0;

#There are also regions which have nuclear power but the share of electricity coming from nuclear power is unknown. In these cases, I have decided to leave the values as NULL.

-- 4. Unnecessary Data --
#The website and year of update are irrelevant for the companies data so those columns can be deleted
ALTER TABLE reactors_parent_companies
DROP COLUMN `Parent Company Website`;

ALTER TABLE reactors_parent_companies
DROP COLUMN `Year of Update`;

# Many columns can be removed from the uranium prices data since only the total average price will be of importance.
ALTER TABLE uranium_price_us
DROP COLUMN `Purchased from US producers`;
ALTER TABLE uranium_price_us
DROP COLUMN `Purchased from US brokers and traders`;
 ALTER TABLE uranium_price_us
 DROP COLUMN `Purchased from foreign suppliers`;
 ALTER TABLE uranium_price_us
 DROP COLUMN `USorigin uranium`;
 ALTER TABLE uranium_price_us
 DROP COLUMN `Foreignorigin uranium`;
 ALTER TABLE uranium_price_us
 DROP COLUMN `Spot contracts`;
 ALTER TABLE uranium_price_us
 DROP COLUMN`Short medium and longterm contracts`;










