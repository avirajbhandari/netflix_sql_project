-- Netflix Project

CREATE TABLE netflix
(
	show_id VARCHAR(10),
	type VARCHAR(10),	
	title VARCHAR (104),
	director VARCHAR(208),	
	casts VARCHAR(1000),	
	country_date_added VARCHAR(50),	
	release_year VARCHAR(10),	
	rating_duration VARCHAR(15),	
	listed_in VARCHAR(100),	
	description VARCHAR(250)

);

SELECT * FROM netflix;


SELECT 
	COUNT(*) as total_content
FROM netflix;

SELECT 
	DISTINCT type
FROM netflix;

-- 15 Business Problems

-- 1. Count the number of Movies vs TV shows

SELECT 
	type,
	COUNT(*) as total_cotent
FROM netflix
GROUP BY type;

-- 2. Find the most commmon rating for movies and TV shows

SELECT 
	type,
	rating 
FROM 

(
	SELECT
		type, 
		rating, 
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	
	FROM netflix
	GROUP BY 1, 2
	--ORDER BY 1, 3 DESC
) as t1

WHERE ranking = 1;


-- 3. List all the movies released in a specific year (e.g., 2020)

SELECT *
FROM netflix
WHERE 
	type = 'Movie' 
	AND 
	release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix;

SELECT
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	COUNT(*) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

/*
SELECT 
	country, 
	total,
	ranking
FROM 

(
SELECT  
    country,  
    COUNT(*) AS total,  
    RANK() OVER(ORDER BY COUNT(*) DESC) AS ranking
FROM netflix
WHERE  country IS NOT NULL
GROUP BY country
ORDER BY total DESC
) as t2

WHERE RANKING <= 5; 
*/

-- 5. Identify the longest movie

SELECT * FROM netflix
WHERE title = 'Black Mirror: Bandersnatch';

SELECT 
    title,
    CAST(REPLACE(duration, ' min', '') AS INTEGER) AS minutes
FROM netflix
WHERE type = 'Movie'
  AND duration IS NOT NULL
ORDER BY minutes DESC
LIMIT 1;

-- 6. Find the content added in the last 5 years

SELECT 
    *
FROM netflix
WHERE date_added IS NOT NULL
  AND TO_DATE(TRIM(date_added), 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT *
FROM netflix 
WHERE director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT 
    *
FROM netflix
WHERE type = 'TV Show'
  AND duration IS NOT NULL
  AND SPLIT_PART(duration, ' ', 1)::numeric > 5;

/*
SELECT 
    *,
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS seasons
FROM netflix
WHERE type = 'TV Show'
  AND duration IS NOT NULL
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5;
*/


-- 9. Count the number of content items in each genre


SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre,
    COUNT(*) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

-- 10. Find each year and the average number of content release by India on netflix.
-- return top 5 year with highest avg content release!

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List all the movies that are documentries 

SELECT *
FROM 
	netflix
WHERE 
	listed_in ILIKE '%Documentaries%'
AND 
	type = 'Movie';

-- 12. Find all the content without a director

SELECT * 
FROM netflix
WHERE director IS null; 

-- 13. Find how many movies where actor 'Salman Khan' appeared in the last 10 years

SELECT *
FROM netflix 
WHERE 
	casts LIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14. Find the top 10 actors who appeared in the highest number of movies produced in India

SELECT
	UNNEST(STRING_TO_ARRAY(casts, ',')) as casts,
	COUNT(*) as total_content
FROM
(
SELECT *
FROM netflix
WHERE 
	country = 'India'
	AND 
	type = 'Movie'
) as t1

GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- 15.  Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

SELECT category, COUNT(*)
FROM

(
SELECT 
    title, description,
    CASE 
        WHEN description ILIKE '%kill%' 
          OR description ILIKE '%violence%' 
        THEN 'Bad'
        ELSE 'Good'
    END AS category
FROM netflix
)

GROUP BY 1; 
	

	

