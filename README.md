# Netflix SQL Data Analysis Project

## Overview

This project analyzes Netflix movies and TV shows using PostgreSQL. I completed this project as part of my SQL learning journey, using a guided YouTube project as the foundation and then writing, testing, debugging, and understanding the queries myself.

The goal of this project was to practice using SQL to answer business-style questions from a real-world dataset. The analysis focuses on Netflix content trends, including content type, ratings, countries, release years, genres, actors, directors, duration, and keyword-based content categorization.

This project helped me strengthen my SQL fundamentals while also improving my ability to think analytically about business questions.

---

## Project Inspiration

This project was inspired by a YouTube SQL portfolio project. I used it as a learning guide and personalized the work by practicing the queries myself, debugging errors, understanding the logic behind each query, and connecting the analysis to business-style questions.

The purpose of this repository is to document my SQL practice and demonstrate my ability to use SQL for data analysis.

---

## Dataset

The dataset used in this project comes from Kaggle:

**Netflix Movies and TV Shows Dataset**  
https://www.kaggle.com/datasets/shivamb/netflix-shows

The dataset contains information about Netflix titles, including:

- Title
- Type of content
- Director
- Cast
- Country
- Date added
- Release year
- Rating
- Duration
- Genre
- Description

---

## Tools Used

- PostgreSQL
- pgAdmin
- SQL
- Kaggle Dataset
- GitHub

---

## Schema

```sql
DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

---

## Business Questions Answered

1. Count the number of Movies vs TV Shows.
2. Find the most common rating for Movies and TV Shows.
3. List all movies released in a specific year.
4. Find the top 5 countries with the most Netflix content.
5. Identify the longest movie.
6. Find content added in the last 5 years.
7. Find all movies or TV shows by a specific director.
8. List all TV shows with more than 5 seasons.
9. Count the number of content items in each genre.
10. Find the top years for Indian Netflix content releases.
11. List all movies categorized as documentaries.
12. Find all content without a director.
13. Find how many movies Salman Khan appeared in during the last 10 years.
14. Find the top 10 actors appearing in Indian-produced movies.
15. Categorize content based on keywords such as "kill" and "violence."

---

## SQL Queries

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;
```

**Objective:**  
Determine the distribution of content types on Netflix.

---

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
WITH rating_count AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS total_rating
    FROM netflix
    WHERE rating IS NOT NULL
    GROUP BY type, rating
),

ranked_rating AS (
    SELECT
        type,
        rating,
        total_rating,
        RANK() OVER(PARTITION BY type ORDER BY total_rating DESC) AS ranking
    FROM rating_count
)

SELECT
    type,
    rating,
    total_rating
FROM ranked_rating
WHERE ranking = 1;
```

**Objective:**  
Find the most common rating for each content type.

---

### 3. List All Movies Released in a Specific Year

```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND release_year = 2020;
```

**Objective:**  
Retrieve all movies released in a specific year.

---

### 4. Find the Top 5 Countries with the Most Netflix Content

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
    COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY new_country
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:**  
Identify the top 5 countries with the highest number of Netflix titles.

---

### 5. Identify the Longest Movie

```sql
SELECT
    title,
    duration,
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS minutes
FROM netflix
WHERE type = 'Movie'
  AND duration IS NOT NULL
ORDER BY minutes DESC
LIMIT 1;
```

**Objective:**  
Find the movie with the longest duration.

---

### 6. Find Content Added in the Last 5 Years

```sql
SELECT *
FROM netflix
WHERE date_added IS NOT NULL
  AND TO_DATE(TRIM(date_added), 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:**  
Retrieve Netflix content added in the last five years.

---

### 7. Find All Movies or TV Shows by Director Rajiv Chilaka

```sql
SELECT *
FROM (
    SELECT
        *,
        TRIM(UNNEST(STRING_TO_ARRAY(director, ','))) AS director_name
    FROM netflix
    WHERE director IS NOT NULL
) AS director_split
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:**  
Find all content directed by Rajiv Chilaka.

---

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT
    title,
    duration,
    CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) AS seasons
FROM netflix
WHERE type = 'TV Show'
  AND duration IS NOT NULL
  AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5
ORDER BY seasons DESC;
```

**Objective:**  
Identify TV shows with more than five seasons.

---

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS genre,
    COUNT(*) AS total_content
FROM netflix
WHERE listed_in IS NOT NULL
GROUP BY genre
ORDER BY total_content DESC;
```

**Objective:**  
Count how many Netflix titles belong to each genre.

---

### 10. Find the Top Years for Indian Netflix Content Releases

```sql
WITH country_split AS (
    SELECT
        show_id,
        release_year,
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country
    FROM netflix
    WHERE country IS NOT NULL
      AND release_year IS NOT NULL
)

SELECT
    release_year,
    COUNT(show_id) AS total_indian_content,
    ROUND(
        COUNT(show_id)::numeric / SUM(COUNT(show_id)) OVER() * 100,
        2
    ) AS percent_of_indian_content
FROM country_split
WHERE new_country = 'India'
GROUP BY release_year
ORDER BY percent_of_indian_content DESC
LIMIT 5;
```

**Objective:**  
Find the top 5 release years that account for the highest percentage of Indian Netflix content.

---

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND listed_in ILIKE '%Documentaries%';
```

**Objective:**  
Retrieve all movies categorized as documentaries.

---

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

**Objective:**  
Find Netflix titles that do not have a director listed.

---

### 13. Find How Many Movies Salman Khan Appeared in During the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE type = 'Movie'
  AND casts ILIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:**  
Find movies featuring Salman Khan that were released in the last 10 years.

---

### 14. Find the Top 10 Actors in Indian Movies

```sql
SELECT
    TRIM(actor) AS actor,
    COUNT(*) AS total_movies
FROM netflix
CROSS JOIN LATERAL UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor
WHERE country ILIKE '%India%'
  AND type = 'Movie'
  AND casts IS NOT NULL
GROUP BY TRIM(actor)
ORDER BY total_movies DESC
LIMIT 10;
```

**Objective:**  
Identify the actors who appeared most frequently in Indian Netflix movies.

---

### 15. Categorize Content Based on Keywords

```sql
SELECT
    category,
    COUNT(*) AS content_count
FROM (
    SELECT
        CASE
            WHEN description ILIKE '%kill%'
              OR description ILIKE '%violence%'
            THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
```

**Objective:**  
Categorize Netflix content based on whether the description contains keywords such as "kill" or "violence."

---

## Key SQL Skills Practiced

This project helped me practice the following SQL concepts:

- `SELECT`
- `WHERE`
- `GROUP BY`
- `ORDER BY`
- `COUNT()`
- `ROUND()`
- Type casting
- `CASE WHEN`
- Subqueries
- Common Table Expressions
- Window functions
- `RANK()`
- `STRING_TO_ARRAY()`
- `UNNEST()`
- `SPLIT_PART()`
- `TO_DATE()`
- `ILIKE`
- Data cleaning using SQL

---

## What I Learned

This project helped me become more confident with SQL by working through a real dataset instead of only practicing simple examples.

One of the biggest things I learned was that real-world datasets are often messy. Columns such as `country`, `casts`, `director`, and `listed_in` contain multiple values inside a single field, so I had to use functions like `STRING_TO_ARRAY()` and `UNNEST()` to split them properly.

I also learned the importance of understanding the business question before writing the query. For example, calculating the percentage of Indian Netflix content by year is different from simply counting Indian Netflix releases by year. Working through these differences helped me improve both my SQL logic and my analytical thinking.

---

## Findings

Some of the main insights explored in this project include:

- Netflix contains both Movies and TV Shows, with Movies making up a major portion of the dataset.
- Ratings vary by content type, and ranking functions can be used to identify the most common rating for each type.
- Some countries appear frequently as content producers, but country data often needs to be cleaned because multiple countries can appear in one row.
- Movie durations can be converted from text into numbers using `SPLIT_PART()` and type casting.
- TV Show seasons can also be extracted from the `duration` column.
- Genre, actor, country, and director analysis often requires splitting comma-separated values.
- Keyword-based categorization can be done using `CASE WHEN` and `ILIKE`.

---

## Conclusion

This project gave me hands-on experience using PostgreSQL to analyze a real-world dataset. It strengthened my ability to clean data, write analytical queries, and turn raw information into useful insights.

It also helped me build a stronger foundation for data analyst, data operations, business intelligence, and finance-related analytics roles.

---

## License

This project is licensed under the MIT License.

---

## Author

**Abhyudaya Rajbhandari**

Economics and Mathematics graduate with interests in data analytics, finance, consulting, and business operations.

I am using projects like this to build my technical foundation in SQL, data analysis, and business problem-solving.
