use mavenmovies;

select count(*)
from rental;

select count(*)
from inventory;

select count(*)
from FILM;

select count(*)
from COSTOMER;

select sum(AMOUNT)
FROM PAYMENT;

--PROVIDE REVENUE TREND FOR INVESTOR

select X.YEAR,X.MONTH_NAME,sum(AMOUNT)AS REVENUE
FROM(select *,extract(YEAR FROM PAYMENT_DATE)AS YEAR,date_format(PAYMENT_DATE,"%B")AS MONTH_NAME
FROM PAYMENT)AS X
group by X.YEAR,X.MONTH_NAME;

__PROVIDE A LIST OF TOP 10 CUSTOMER BEASD ON REVENUE TO PUSH OFFER TO THEM

SELECT X.CUSTOMER_ID
FROM(SELECT CUSTOMER_ID,SUM(AMOUNT)AS REVENUE_FROM_CUSTOMER
FROM PAYMENT 
GROUP BY CUSTOMER_ID
ORDER BY REVENUE_FROM_CUSTOMER DESC
LIMIT 10)AS X ;



SELECT *
FROM CUSTOMER
where CUSTOMER_ID in(SELECT X.CUSTOMER_ID
FROM(SELECT CUSTOMER_ID,SUM(AMOUNT)AS REVENUE_FROM_CUSTOMER
FROM PAYMENT 
GROUP BY CUSTOMER_ID
ORDER BY REVENUE_FROM_CUSTOMER DESC
LIMIT 10)AS X );

-- DATA ANALYSIS PROJECT FOR RENTAL MOVIES BUSINESS
-- THE STEPS INVOLVED ARE EDA, UNDERSTANDING THR SCHEMA AND ANSWERING THE AD-HOC QUESTIONS
-- BUSINESS QUESTIONS LIKE EXPANDING MOVIES COLLECTION AND FETCHING EMAIL IDS FOR MARKETING ARE INCLUDED
-- HELPING COMPANY KEEP A TRACK OF INVENTORY AND HELP MANAGE IT.

-- You need to provide customer firstname, lastname and email id to the marketing team --

select FIRST_NAME,LAST_NAME,EMAIL
FROM CUSTOMER;

-- How many movies are with rental rate of $0.99? --

SELECT count(*)AS CHEAPEST_RENTALS
FROM FILM
WHERE RENTAL_RATE = 0.99;

-- We want to see rental rate and how many movies are in each rental category --

SELECT RENTAL_RATE,COUNT(*)
FROM FILM 
group by RENTAL_RATE;

-- Which rating has the most films? -

select RATTING,COUNT(*)AS NUMBER_OF_MOVIE
FROM FILM 
group by RATTING
order by NUMBER_OF_MOVIE desc
limit 1;

-- Which rating is most prevalant in each store? --
select INV.STORE_ID,F.RATING,COUNT(INV.INVENTORY_ID)AS NUMBER_OF_COPIES
FROM INVENTORY AS INV LEFT JOIN FILM AS F
ON INV .FILM_ID= F.FILM_ID
GROUP BY INV.STORE_ID,F.RATING
order by NUMBER_OF_COPIES DESC;

-- List of films by Film Name, Category, Language --
select F.FILM_ID,F.TITLE,C.NAME AS CATEGORY_NAME, LANG AS LANGUGE
FROM FILM AS F LEFT JION FILM_CATEGORY AS FC
ON F.FILM_ID = FC.FILM_ID LEFT JOIN CATEGORY AS C
ON FC.CATEGORY_ID = C.CATEGORY_ID LEFT JOIN LANGUAGE AS LUNG
ON F.LANGUAGE_ID = LANG.LANGUAGE_ID;

-- HOW MANY EACH MOVIE HAS BEEN RENTED OUT?
select F.TITLE,count(RENTAL_ID)AS NUMBER_OF_RENTALS
FROM RENTAL AS R LEFT JOIN INVENTORY AS INV
ON R.INVENTORY_ID = INV.INVENTORY_ID LEFT JOIN FILM AS F 
ON INV.FILM_ID = F.FILM_ID
GROUP BY F.TITLE
order by NUMBER_OF_RENTALS desc;

-- REVENUE PER FILM (TOP 10 GROSSRES)--
SELECT F.TITLE,SUM(P.AMOUNT) AS REVENUE_PER_FILM
FROM
    PAYMENT AS P
        LEFT JOIN
    RENTAL AS R ON P.RENTAL_ID = R.RENTAL_ID
        LEFT JOIN
    INVENTORY AS INV ON R.INVENTORY_ID = INV.INVENTORY_ID
        LEFT JOIN
    FILM AS F ON INV.FILM_ID = F.FILM_ID
group by F.TITLE
order by REVENUE_PER_FILM desc limit 10;

-- Which Store has historically brought the most revenue?
SELECT ST.STORE_ID,SUM(P.AMOUNT)AS REVENUE_PER_STORE
FROM PAYMENT AS P LEFT JOIN STAFF AS ST
ON P.STAFF_ID=ST.STAFF_ID
GROUP BY ST.STORE_ID;

-- Reward users who have rented at least 30 times (with details of customers)
SELECT customer_id,count(rental_id)as number_of_rental
FROM RENTAL
group by customer_id
having number_of_rental >=30
order by customer_id;


-- Could you pull all payments from our first 100 customers (based on customer ID)
select customer_id,rental_id,amount,payment_date
from payment
where customer_id<101;

-- Now I’d love to see just payments over $5 for those same customers, since January 1, 2006
select customer_id,rental_id,amount,payment_date
from payment
where customer_id<101 and amount>5 and payment_date> "2006-01-01";

-- Now, could you please write a query to pull all payments from those specific customers, along
-- with payments over $5, from any customer?
select customer_id,rental_id,AMOUNT,payment_date
FROM payment
WHERE AMOUNT>5 AND CUSTOMER_ID IN (42,53,60,75);

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?
select title,special_features
from film
where special_features like '%Behind the Scenes%' ;

-- unique movie ratings and number of movies
select rating,count(film_id)as Number_of_movies
from film
group by rating;

-- Could you please pull a count of titles sliced by rental duration?
select rental_duration,count(film_id)as number_of_films
from film
group by rental_duration;
-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION
select rating,
      count(film_id)as number_of_films,
      min(length)as short_film,
      max(length)as long_film,
      avg(length)as avg_film_lenght,
      avg(rental_duration)as avg_rental_duration
from film
group by rating
order by avg_film_lenght;

-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?


SELECT REPLACEMENT_COST,
	COUNT(FILM_ID) AS NUMBER_OF_FILMS,
    MIN(RENTAL_RATE) AS CHEAPEST_RENTAL,
    MAX(RENTAL_RATE) AS EXPENSIVE_RENTAL,
    AVG(RENTAL_RATE) AS AVERAGE_RENTAL
FROM FILM
GROUP BY REPLACEMENT_COST
ORDER BY REPLACEMENT_COST;



-- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”


SELECT CUSTOMER_ID,COUNT(*) AS TOTAL_RENTALS
FROM RENTAL
GROUP BY CUSTOMER_ID
HAVING TOTAL_RENTALS < 15;

-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

SELECT TITLE,LENGTH,RENTAL_RATE
FROM FILM
ORDER BY LENGTH DESC
LIMIT 20;

-- CATEGORIZE MOVIES AS PER LENGTH

	CASE
		WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17','R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
	END AS FIT_FOR_RECOMMENDATTION
FROM FILM;


-- “I’d like to know which store each customer goes to, and whether or
-- not they are active. Could you pull a list of first and last names of all customers, and
-- label them as either ‘store 1 active’, ‘store 1 inactive’, ‘store 2 active’, or ‘store 2 inactive’?”


SELECT CUSTOMER_ID,FIRST_NAME,LAST_NAME,
	CASE
		WHEN STORE_ID = 1 AND ACTIVE = 1 THEN 'store 1 active'
        WHEN STORE_ID = 1 AND ACTIVE = 0 THEN 'store 1 inactive'
        WHEN STORE_ID = 2 AND ACTIVE = 1 THEN 'store 2 active'
        WHEN STORE_ID = 2 AND ACTIVE = 0 THEN 'store 2 inactive'
        ELSE 'ERROR'
	END AS STORE_AND_STATUS
FROM CUSTOMER;


-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id. Thanks!”

SELECT DISTINCT INVENTORY.INVENTORY_ID,
				INVENTORY.STORE_ID,
                FILM.TITLE,
                FILM.DESCRIPTION 
FROM FILM INNER JOIN INVENTORY ON FILM.FILM_ID = INVENTORY.FILM_ID;

-- Actor first_name, last_name and number of movies

SELECT * FROM FILM_ACTOR;
SELECT * FROM ACTOR;

SELECT 
	ACTOR.ACTOR_ID,
    ACTOR.FIRST_NAME,
    ACTOR.LAST_NAME,
    COUNT(FILM_ACTOR.FILM_ID) AS NUMBER_OF_FILMS
FROM ACTOR
	LEFT JOIN FILM_ACTOR
		ON ACTOR.ACTOR_ID= FILM_ACTOR.ACTOR_ID
GROUP BY
	ACTOR.ACTOR_ID;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

SELECT FILM.TITLE,
	COUNT(FILM_ACTOR.ACTOR_ID) AS NUMBER_OF_ACTORS
FROM FILM 
	LEFT JOIN FILM_ACTOR
		ON FILM.FILM_ID = FILM_ACTOR.FILM_ID
GROUP BY 
	FILM.TITLE;
    
-- “Customers often ask which films their favorite actors appear in. It would be great to have a list of
-- all actors, with each title that they appear in. Could you please pull that for me?”
    
SELECT ACTOR.FIRST_NAME,
		ACTOR.LAST_NAME,
        FILM.TITLE
FROM ACTOR INNER JOIN FILM_ACTOR
	ON ACTOR.ACTOR_ID = FILM_ACTOR.ACTOR_ID
			INNER JOIN FILM
	ON FILM_ACTOR.FILM_ID = FILM.FILM_ID
ORDER BY
ACTOR.LAST_NAME,
ACTOR.FIRST_NAME;

-- “The Manager from Store 2 is working on expanding our film collection there.
-- Could you pull a list of distinct titles and their descriptions, currently available in inventory at store 2?”

SELECT DISTINCT FILM.TITLE,
	FILM.DESCRIPTION
FROM FILM
	INNER JOIN INVENTORY
		ON FILM.FILM_ID = INVENTORY.FILM_ID
        AND INVENTORY.STORE_ID = 2;

-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? Thanks!”

SELECT * FROM STAFF;
SELECT * FROM ADVISOR;

(SELECT FIRST_NAME,
		LAST_NAME,
        'ADVISORS' AS DESIGNATION
FROM ADVISOR

UNION

SELECT FIRST_NAME,
		LAST_NAME,
        'STAFF MEMBER' AS DESIGNATION
FROM STAFF);