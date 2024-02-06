-- DATA EXPLORATION:
-- Identify tables in the database
SHOW TABLES;

-- Detailed overview of the tables
SHOW TABLE STATUS;

-- The "DESCRIBE" phrase can also be use
DESCRIBE TABLE track_detail;
DESCRIBE TABLE track_figures;


/*Identify the relationship between the tables
The purpose of SHOW CREATE TABLE is primarily for informational and administrative tasks, 
allowing users to: It shows the column names, data types, default values, 
and any constraints (such as primary keys, foreign keys, unique constraints, etc*/
SHOW CREATE TABLE track_detail;
SHOW CREATE TABLE track_figures;


-- Check for Missing Values for the  columns
SELECT 
    COUNT(*) AS MISSING_VALUES_1
FROM
    track_detail
WHERE
    track_ID IS NULL OR artists_name IS NULL
        OR track_duration_ms IS NULL
        OR track_release_date IS NULL
        OR track_year IS NULL;

        
SELECT 
    COUNT(*) AS MISSING_VALUES_2
FROM
    track_figures
WHERE
    track_figure_ID IS NULL
        OR track_acousticness IS NULL
        OR track_danceability IS NULL
        OR track_energy IS NULL
        OR track_instrumentalness IS NULL
        OR track_liveness IS NULL
        OR track_loudness IS NULL
        OR track_speechiness IS NULL
        OR track_tempo IS NULL
        OR track_valence IS NULL
        OR track_mode IS NULL
        OR track_key IS NULL
        OR track_popularity IS NULL
        OR track_explicit IS NULL;


-- checking for Duplicates in the tables:
SELECT 
    track_ID, COUNT(*) AS DUPLICATES_1
FROM
    track_detail
GROUP BY track_ID
HAVING COUNT(*) > 1;

SELECT 
    track_figure_ID, COUNT(*) AS DUPLICATES_2
FROM
    track_figures
    GROUP BY track_figure_ID
HAVING COUNT(*) > 1;


-- checking for Anomalies:
SELECT * FROM track_detail;
SELECT * FROM track_figures;


/*We can delete the "track_release_date" column if 
we wish to since some of the date is incomplete*/
ALTER TABLE track_detail
DROP COLUMN track_release_date;


-- basic queries
-- Utilize SELECT
SELECT 
    track_ID, track_name
FROM
    track_detail;
SELECT 
    *
FROM
    track_figures; 


-- WHERE
SELECT 
    track_figure_ID AS IDs_BY_POPULARITY
FROM
    track_figures
WHERE
    track_popularity > 70;


-- GROUP BY
SELECT DISTINCTROW
    track_name, artists_name AS TRACKS
FROM
    track_detail
GROUP BY track_ID;


-- ORDER BY
SELECT 
    track_ID, track_figure_ID AS TRACK_POPULARITY
FROM
    track_figures
WHERE
    track_popularity > 80
ORDER BY track_ID;


/*perform join operations
inner join: Returns only the rows that have matching values in both tables*/
SELECT 
    track_name, artists_name,track_popularity
FROM
    track_detail
        INNER JOIN
    tracK_figures ON track_detail.track_ID = tracK_figures.track_ID;



/*left join: Returns all rows from the left table (track_detail), 
and the matched rows from the right table (track_figures),
If there's no match, NULL values are returned from the right side*/
SELECT 
    track_name, artists_name, track_year, track_energy, track_tempo, track_figure_ID
FROM
    track_detail
        LEFT JOIN
    track_figures ON track_detail.track_ID = track_figures.track_id;



/*right join: Returns all rows from the right table (track_figures), 
and the matched rows from the left table (track_detail). 
If there's no match, NULL values are returned from the left side.*/
SELECT 
    track_name, artists_name, track_popularity, track_mode, track_danceability
FROM
    track_detail
        RIGHT JOIN
    track_figures ON track_detail.track_ID = track_figures.track_ID;


/*full join: Returns all rows when there is a match in either table. 
If there's no match, NULL values are returned for the missing side*/
SELECT 
    track_figures, artists_name, track_year, track_tempo, track_mode, track_energy
FROM
    track_detail 
		FULL JOIN
    track_figures ON track_detail.track_ID = track_figures.track_ID;


/*Data Transformation
Retrieve average track duration and total number of tracks*/
SELECT 
    AVG(track_duration_ms) AS avg_duration,
    COUNT(*) AS total_tracks
FROM
    track_detail;


-- Extract year from track_release_date
SELECT 
    track_ID,
    track_name,
    artists_name,
    track_duration_ms,
    track_release_date,
    track_year,
    SUBSTRING(track_release_date, 1, 4) AS release_year
FROM
    track_detail;


-- Calculate total popularity, handling NULL values
SELECT 
    SUM(IFNULL(track_popularity, 0)) AS total_popularity
FROM
    track_figures;


/*calculate the average track popularity for each year, 
along with the percentage change in popularity compared to the previous year*/
WITH PopularityByYear AS (
    SELECT 
        track_year,
        AVG(track_popularity) AS avg_popularity
    FROM 
        track_detail
    JOIN 
        track_figures ON track_detail.track_ID = track_figures.track_ID
    GROUP BY 
        track_year
),
PopularityChange AS (
    SELECT 
        track_year,
        avg_popularity,
        LAG(avg_popularity) OVER (ORDER BY track_year) AS prev_year_avg_popularity,
        ((avg_popularity - LAG(avg_popularity) OVER (ORDER BY track_year)) / LAG(avg_popularity) OVER (ORDER BY track_year)) * 100 AS popularity_change_percent
    FROM 
        PopularityByYear
)
SELECT 
    track_year,
    avg_popularity,
    popularity_change_percent
FROM 
    PopularityChange;


-- Threshold for outlier detection, z-score greater than 3
WITH PopularityStats AS (
    SELECT 
        track_ID,
        track_popularity,
        AVG(track_popularity) OVER () AS avg_popularity,
        STDDEV_POP(track_popularity) OVER () AS stddev_popularity
    FROM 
        track_figures
),
Outliers AS (
    SELECT 
        track_ID,
        track_popularity,
        (track_popularity - avg_popularity) / stddev_popularity AS z_score
    FROM 
        PopularityStats
)
SELECT 
    track_ID,
    track_popularity
FROM 
    Outliers
WHERE 
    z_score > 3; 


-- Yearly Popularity
WITH YearlyPopularity AS (
    SELECT 
        track_year,
        AVG(track_popularity) AS avg_popularity
    FROM 
        track_detail
    JOIN 
        track_figures ON track_detail.track_ID = track_figures.track_ID
    GROUP BY 
        track_year
)
SELECT 
    track_year,
    avg_popularity
FROM 
    YearlyPopularity
ORDER BY 
    track_year;


-- Explicit Content Trend Analysis
WITH YearlyExplicit AS (
    SELECT 
        track_year,
        SUM(track_explicit) AS total_explicit,
        COUNT(*) AS total_tracks
    FROM 
        track_detail
	JOIN 
        track_figures ON track_detail.track_ID = track_figures.track_ID
    GROUP BY 
        track_year
)
SELECT 
    track_year,
    total_explicit,
    total_tracks,
    ROUND((total_explicit * 100.0) / total_tracks, 2) AS percentage_explicit
FROM 
    YearlyExplicit
ORDER BY 
    track_year;


-- Duration-Based Trend Analysis
WITH YearlyDuration AS (
    SELECT 
        track_year,
        AVG(track_duration_ms) AS avg_duration_ms
    FROM 
        track_detail
    GROUP BY 
        track_year
)
SELECT 
    track_year,
    avg_duration_ms / 60000 AS avg_duration_minutes
FROM 
    YearlyDuration
ORDER BY 
    track_year;


-- Mode and Key Trend Analysis
WITH ModeKeyDistribution AS (
    SELECT 
        track_year,
        track_mode,
        track_key,
        COUNT(*) AS track_count
    FROM 
        track_detail
	JOIN 
        track_figures ON track_detail.track_ID = track_figures.track_ID
    GROUP BY 
        track_year, track_mode, track_key
)
SELECT 
    track_year,
    track_mode,
    track_key,
    track_count,
    ROUND((track_count * 100.0) / SUM(track_count) OVER (PARTITION BY track_year), 2) AS percentage_of_total
FROM 
    ModeKeyDistribution
ORDER BY 
    track_year, track_mode, track_key;