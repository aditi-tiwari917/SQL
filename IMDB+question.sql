USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT 'movie' AS table_name, COUNT(*) AS total_rows FROM movie
UNION
SELECT 'genre' AS table_name, COUNT(*) AS total_rows FROM genre
UNION
SELECT 'director_mapping' AS table_name, COUNT(*) AS total_rows FROM director_mapping;










-- Q2. Which columns in the movie table have null values?
-- Type your code below:

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'movie' AND is_nullable = 'YES';








-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- Total number of movies released each year
SELECT year (date_published)as year, COUNT(*) AS number_of_movies
FROM movie
GROUP BY year(date_published)
ORDER BY Year;

-- Month-wise trend of movies released
SELECT MONTH(date_published) AS month_num, COUNT(*) AS number_of_movies
FROM movie
GROUP BY MONTH(date_published)
ORDER BY month_num;









/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
SELECT COUNT(*)  AS number_of_movies
FROM movie
WHERE YEAR(date_published) = 2019 
AND (country = 'USA' OR country = 'India');










/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT DISTINCT genre
FROM genre;










/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT 
    genre, COUNT(movie_id) AS no_of_movies
FROM
    genre 
GROUP BY genre
ORDER BY COUNT(movie_id) DESC;









/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
WITH mov_info AS 
(
SELECT 
    *, COUNT(movie_id) AS num_movies
FROM
    genre
GROUP BY movie_id
HAVING COUNT(movie_id) = 1
)
SELECT 
    COUNT(*) AS num_distinct_movie
FROM
    mov_info;









/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
    genre, ROUND(AVG(duration)) AS avg_duration
FROM
    genre AS g
        INNER JOIN
    movie AS m ON g.movie_id = m.id
GROUP BY genre
ORDER BY avg_duration DESC;










/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

WITH genre_rank AS
(
SELECT 
    genre, 
    COUNT(movie_id) as movie_count,
    RANK() OVER(ORDER BY COUNT(movie_id) DESC) AS genre_rank
FROM genre
GROUP BY genre
)
SELECT * FROM genre_rank
WHERE genre = 'Thriller';

        








/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT 
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM 
    ratings;






    

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
WITH ratings_rank AS
(
SELECT title,
       avg_rating,
       DENSE_RANK() OVER(ORDER BY avg_rating DESC) AS movie_rank
FROM ratings AS r
       INNER JOIN movie AS m
               ON r.movie_id = m.id
)
SELECT * FROM ratings_rank
WHERE movie_rank <= 10;








/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
    median_rating, COUNT(movie_id)
FROM
    ratings

GROUP BY median_rating
ORDER BY median_rating;









/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:


WITH prod_rank
     AS (SELECT production_company,
                Count(id) AS movie_count,
                Rank() OVER(ORDER BY Count(id) DESC) AS prod_company_rank
         FROM   movie AS m
                INNER JOIN ratings AS r
                        ON m.id = r.movie_id
         WHERE  avg_rating > 8
                AND production_company IS NOT NULL
         GROUP  BY production_company)
SELECT *
FROM   prod_rank
WHERE  prod_company_rank = 1; 







-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
    genre, COUNT(g.movie_id) AS movie_count
FROM
    genre AS g
        INNER JOIN
    ratings AS r USING (movie_id)
        INNER JOIN
    movie AS m ON r.movie_id = m.id
WHERE
		total_votes > 1000 
		AND year = 2017
		AND MONTH(date_published) = 3
		AND country LIKE '%USA%'
GROUP BY genre
ORDER BY movie_count DESC;










-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
    title, avg_rating, genre
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
        INNER JOIN
    genre AS g ON m.id = g.movie_id
WHERE
    title LIKE 'The%' AND avg_rating > 8
ORDER BY
	avg_rating DESC;







-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT 
    COUNT(id) AS movie_count
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
WHERE
    date_published BETWEEN '2018-04-01' AND '2019-04-01'
        AND median_rating = 8;








-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
SELECT 
    country, SUM(total_votes) AS sum_total_votes
FROM
    ratings AS r
        INNER JOIN
    movie AS m ON r.movie_id = m.id
WHERE
    country = 'Germany' OR country = 'Italy'
GROUP BY country;







-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) AS name_nulls,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) AS height_nulls,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS date_of_birth_nulls,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS known_for_movie_nulls
FROM
    names;







/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
CREATE VIEW top_3_genre AS
(
SELECT 
    genre
FROM
    genre AS g
        INNER JOIN
    ratings AS r USING (movie_id)
WHERE
    avg_rating > 8
GROUP BY genre
ORDER BY COUNT(g.movie_id) DESC
LIMIT 3);
-- We found out the top 3 genres and saved them as a view.

SELECT 
    name as Director_name, genre, COUNT(dm.movie_id) as movies_count
FROM
    names n
        INNER JOIN
    director_mapping dm ON n.id = dm.name_id
        INNER JOIN
    genre ON dm.movie_id = genre.movie_id
        INNER JOIN
    ratings ON genre.movie_id = ratings.movie_id
WHERE
    genre IN (SELECT 
            genre
        FROM
            top_3_genre)
        AND avg_rating > 8
GROUP BY name
ORDER BY COUNT(dm.movie_id) DESC
LIMIT 3;







/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

WITH top_actor AS
(
SELECT 
    name AS actor_name, COUNT(rm.movie_id) AS movie_count,
    RANK() OVER(ORDER BY COUNT(rm.movie_id) DESC) AS rank_actor
FROM
    names n
        INNER JOIN
    role_mapping rm ON n.id = rm.name_id
        INNER JOIN
    ratings r ON rm.movie_id = r.movie_id
WHERE
    median_rating>=8
GROUP BY name
)
SELECT * FROM top_actor
WHERE rank_actor <= 2;








/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
WITH prod_rank
     AS (SELECT production_company,
                Sum(total_votes)                    AS vote_count,
                Rank()
                  OVER(
                    ORDER BY Sum(total_votes) DESC) AS prod_comp_rank
         FROM   movie m
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         GROUP  BY production_company)
SELECT *
FROM   prod_rank
WHERE  prod_comp_rank <= 3;









/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT NAME 			  										   AS actor_name,
       Sum(total_votes)   										   AS actor_total_votes,
       Count(rm.movie_id) 										   AS movie_count,
	   ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2)    	   AS avg_actor_rating,
       Rank() OVER(ORDER BY SUM(avg_rating*total_votes)/SUM(total_votes) DESC, 
												 total_votes DESC) AS actor_rank
FROM   names n
       INNER JOIN role_mapping rm
               ON n.id = rm.name_id
       INNER JOIN ratings r
               ON rm.movie_id = r.movie_id
	   INNER JOIN movie m
			   ON r.movie_id = m.id
WHERE country like '%India%'
GROUP  BY NAME
HAVING Count(rm.movie_id) >= 5; 








-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actress_tab AS
(
SELECT NAME 			  										   AS actress_name,
       Sum(total_votes)   										   AS actress_total_votes,
       Count(rm.movie_id) 										   AS movie_count,
	   ROUND(SUM(avg_rating*total_votes)/SUM(total_votes),2)       AS actress_avg_rating,
       Rank() OVER(ORDER BY SUM(avg_rating*total_votes)/SUM(total_votes) DESC, 
												 total_votes DESC) AS actress_rank
FROM   names n
       INNER JOIN role_mapping rm
               ON n.id = rm.name_id
       INNER JOIN ratings r
               ON rm.movie_id = r.movie_id
	   INNER JOIN movie m
			   ON r.movie_id = m.id
WHERE m.country like '%India%' AND m.languages LIKE '%Hindi%' AND rm.category = 'Actress'
GROUP  BY NAME
HAVING Count(rm.movie_id) >= 3
)
SELECT * FROM actress_tab
WHERE actress_rank <= 5;








/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT 
    title,
    genre,
    avg_rating,
    CASE
        WHEN avg_rating > 8 THEN 'Superhit Movie'
        WHEN avg_rating BETWEEN 7 AND 8 THEN 'Hit Movie'
        WHEN avg_rating BETWEEN 5 AND 7 THEN 'One-time watch Movie'
        WHEN avg_rating < 5 THEN 'Flop Movie'
    END AS movie_type
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id
        INNER JOIN
    ratings r USING (movie_id)
WHERE
    genre = 'thriller';









/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT genre,
       Round(Avg(duration), 1) AS avg_duration,
       SUM(Round(Avg(duration), 1))
         over( ORDER BY SUM(duration) DESC ROWS unbounded preceding) AS running_total_duration,
       Avg(Round(Avg(duration), 1))
         over(ORDER BY SUM(duration) DESC ROWS 10 preceding ) AS moving_average_duration
FROM   genre AS g
       inner join movie m
               ON g.movie_id = m.id
GROUP  BY genre;








-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
SELECT 
    worlwide_gross_income
FROM
    movie;
-- We see that $ sign is present in column, therefore we update the column.
UPDATE movie 
SET 
    worlwide_gross_income = REPLACE(worlwide_gross_income, '$ ', '')
WHERE
    worlwide_gross_income IS NOT NULL;

-- Now we have removed the $ sign. Creating a view for top 3 genres

CREATE VIEW top_3_genre_new AS
(
SELECT 
    genre
FROM
    genre AS g
        INNER JOIN
    ratings AS r USING (movie_id)
GROUP BY genre
ORDER BY COUNT(g.movie_id) DESC
LIMIT 3);
WITH top_gross AS
(
SELECT genre,
       year,
       title,
       Sum(worlwide_gross_income) AS 'sum_income(in_$)',
       Dense_Rank()
         OVER(partition BY year ORDER BY Sum(worlwide_gross_income) DESC) AS movie_rank
FROM   genre g
       INNER JOIN movie m
               ON g.movie_id = m.id
WHERE worlwide_gross_income IS NOT NULL AND genre IN (SELECT genre FROM top_3_genre_new)
GROUP  BY genre, year,title 
)
SELECT * FROM top_gross
WHERE movie_rank <= 5;








-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
-- using different logic than the one mentioned in hint.
WITH multi_lang_rank
     AS (WITH multi_lang_info
              AS /*query to mark multi language rows with 1 */
              (SELECT *,
                      CASE
                        WHEN languages LIKE '%,%' THEN 1
                        ELSE 0
                      END AS multi_lang_indic
               FROM movie)
         SELECT production_company,
                Count(id)                    		 AS movie_count,
                Rank() OVER(ORDER BY Count(id) DESC) AS prodcomp_rank
          FROM   multi_lang_info ml
					INNER JOIN 
                 ratings r ON ml.id = r.movie_id
          WHERE  multi_lang_indic = 1
                 AND median_rating >= 8
                 AND production_company IS NOT NULL
          GROUP  BY production_company)
SELECT *
FROM   multi_lang_rank
WHERE  prodcomp_rank <= 2; 








-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH actress_info_rank AS 
(
SELECT NAME 										AS actress_name,
       Sum(total_votes) 							AS total_votes,
       Count(rm.movie_id) 							AS movie_count,
       SUM(avg_rating*total_votes)/SUM(total_votes) AS actress_avg_rating,
       Rank() OVER(ORDER BY Count(rm.movie_id) DESC, 
					SUM(avg_rating*total_votes)/SUM(total_votes) DESC) 
													AS actress_rank 	
									/*If the count of movies is same then avg_raitng will be the deciding factor*/
FROM   names n
       INNER JOIN role_mapping rm
               ON n.id = rm.name_id
       INNER JOIN ratings r using(movie_id)
       INNER JOIN genre g using(movie_id)
WHERE  avg_rating > 8
       AND genre LIKE '%drama%'
       AND category LIKE '%actress%'
GROUP  BY NAME)
SELECT * FROM actress_info_rank
WHERE actress_rank <= 2;








/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH next_date_published_summary AS
(
           SELECT     d.name_id,
                      NAME,
                      d.movie_id,
                      duration,
                      r.avg_rating,
                      total_votes,
                      m.date_published,
                      Lead(date_published,1) OVER(partition BY d.name_id ORDER BY date_published,movie_id ) AS next_date_published
           FROM director_mapping AS d
           INNER JOIN names AS n
           ON         n.id = d.name_id
           INNER JOIN movie AS m
           ON         m.id = d.movie_id
           INNER JOIN ratings AS r
           ON         r.movie_id = m.id ), top_director_summary AS
(
       SELECT *,
              Datediff(next_date_published, date_published) AS date_difference
       FROM   next_date_published_summary )
SELECT   name_id                       AS director_id,
         NAME                          AS director_name,
         Count(movie_id)               AS number_of_movies,
         Round(Avg(date_difference),2) AS avg_inter_movie_days,
         Round(Avg(avg_rating),2)               AS avg_rating,
         Sum(total_votes)              AS total_votes,
         Min(avg_rating)               AS min_rating,
         Max(avg_rating)               AS max_rating,
         Sum(duration)                 AS total_duration
FROM     top_director_summary
GROUP BY director_id
ORDER BY Count(movie_id) DESC limit 9;







