/* Initialize database  */
USE sakila;

/* 1a. Display the first and last names of all actors from the table `actor`. */
SELECT first_name, last_name
FROM   actor;

/* 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. */
SELECT UPPER(CONCAT(first_name, " ", last_name)) AS "Actor Name"
FROM   actor;

/* 2a. Find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." */
SELECT actor_id, first_name, last_name
FROM   actor
WHERE  first_name = "Joe";

/* 2b. Find all actors whose last name contain the letters `GEN`:*/
SELECT actor_id, first_name, last_name
FROM   actor
WHERE  last_name LIKE "%GEN%";

/* 2c. Find all actors whose last names contain the letters `LI`. 
This time, order the rows by last name and first name, in that order */
SELECT actor_id, first_name, last_name
FROM   actor
WHERE  last_name LIKE "%LI%"
ORDER BY last_name, first_name;

/* 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: 
Afghanistan, Bangladesh, and China */
SELECT	country_id, country
FROM	country
WHERE	country IN ("Afghanistan", "Bangladesh", "China");

/* 3a. Add a `middle_name` column to the table `actor`.
Position it between `first_name` and `last_name */
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(45) AFTER first_name;

/* 3b. You realize that some of these actors have tremendously long last names. 
Change the data type of the `middle_name` column to `blobs`. */
ALTER TABLE actor
MODIFY middle_name BLOB;

/* 3c. Now delete the `middle_name` column */
ALTER TABLE actor
DROP COLUMN middle_name;

/* 4a. List the last names of actors, as well as how many actors have that last name */
SELECT 	last_name, COUNT(*) AS "No. of actors"
FROM	actor
GROUP BY last_name;

/* 4b. List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors */
-- Solution 1. Avoid HAVING and use a WHERE clause (faster, HAVING retrieves all rows, WHERE retrieves a subset
SELECT 	t1.last_name, COUNT(*) AS "No. of actors"
FROM	actor AS t1
WHERE	2 <=
		(
		SELECT 	COUNT(*)
		FROM	actor AS t2
		WHERE	t2.last_name = t1.last_name
		)
GROUP BY t1.last_name;

-- Solution 2 using HAVING
SELECT 	last_name, COUNT(*) AS "No. of actors"
FROM	actor
GROUP BY last_name
HAVING COUNT(last_name) >=2;


/* 4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table 
as `GROUCHO WILLIAMS. Write a query to fix the record */

UPDATE 	actor
SET		first_name = "HARPO"
WHERE	first_name = "GROUCHO"
AND		last_name = "WILLIAMS";

/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
It turns out that `GROUCHO` was the correct name after all! 
In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
Otherwise, change the first name to `MUCHO GROUCHO`, 
as that is exactly what the actor will be with the grievous error. 
BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! 
(Hint: update the record using a unique identifier.) */
UPDATE 	actor
SET		first_name = "GROUCHO"
WHERE	actor_id =
		(
		SELECT	t2.actor_id
		FROM	actor as t2
		WHERE	t2.first_name = "HARPO"
		AND		t2.last_name = "WILLIAMS"
		);

/* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? */
-- SOLUTION run below statement, right click on the output.
-- Select "Open Value in Viewer", copy the content in the tab page called "Text" and run it as a statement.
SHOW CREATE TABLE address;

/* 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
Use the tables `staff` and `address` */
SELECT	staff.first_name, staff.last_name, address.address, address.district, address.postal_code
FROM	address 
INNER JOIN staff ON staff.address_id = address.address_id;

/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
Use tables `staff` and `payment`.*/
SELECT	staff.first_name, staff.last_name, SUM(payment.amount) "Total amount"
FROM	payment 
INNER JOIN staff ON staff.staff_id = payment.staff_id
WHERE	DATE_FORMAT(payment.payment_date, "%b-%Y") = "Aug-2005"
GROUP BY staff.first_name, staff.last_name;

/* 6c. List each film and the number of actors who are listed for that film. 
Use tables `film_actor` and `film`. Use inner join. */
SELECT	film.title, COUNT(film_actor.actor_id) "No. of actors"
FROM	film
INNER JOIN	film_actor ON film_actor.film_id = film.film_id
GROUP BY	title;

/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system? */
SELECT	COUNT(*)
FROM	inventory
WHERE	inventory.film_id IN
	(
    SELECT	film_id
	FROM	film
	WHERE	film.title = "Hunchback Impossible"
    );

/* 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
List the customers alphabetically by last name. */
SELECT	customer.customer_id, customer.first_name, customer.last_name, SUM(amount) "Paid per customer"
FROM	customer
INNER JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY	customer.customer_id, first_name, last_name
ORDER BY	customer.last_name;	

/* 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.*/
SELECT	film.title
FROM	film
WHERE	(film.title LIKE 'K%' OR film.title LIKE 'Q%')
AND		film.language_id =
(
SELECT	language_id
FROM	language
WHERE	language.name = "English"
);

/* 7b. Use subqueries to display all actors who appear in the film Alone Trip. */
-- Solution 1 using INNER JOIN
SELECT	first_name, last_name
FROM	actor
INNER JOIN film_actor ON film_actor.actor_id = actor.actor_id
WHERE EXISTS
(
SELECT	'1'
FROM	film
WHERE	film.film_id = film_actor.film_id
AND		film.title = "Alone Trip"
);	

-- Solution 2 using subqueries only
SELECT	first_name, last_name
FROM	actor
WHERE	actor_id IN
	(
    SELECT	actor_id
    FROM	film_actor
	WHERE EXISTS
		(
		SELECT	'1'
		FROM	film
		WHERE	film.film_id = film_actor.film_id
		AND		film.title = "Alone Trip"
		)	
	);

/* 7c. Retrieve the names and email addresses of all Canadian customers. */
SELECT	customer.first_name, customer.last_name, customer.email
FROM	customer
INNER JOIN address ON address.address_id = customer.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country on country.country_id = city.country_id
WHERE country.country = "Canada";


/* 7d.  Identify all movies categorized as family films. */
SELECT	film.title, category.name
FROM	film
INNER JOIN film_category ON film_category.film_id = film.film_id
INNER JOIN category ON category.category_id = film_category.category_id
WHERE	category.name = "Family";

/* 7e. Display the most frequently rented movies in descending order. */
SELECT	film.title, COUNT(*) AS "Total rented"
FROM	film
INNER JOIN inventory ON inventory.film_id = film.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
GROUP BY film.title
ORDER BY 2 DESC;

/* 7f. Write a query to display how much business, in dollars, each store brought in. */
/* Revenue is allocated to as store based on rentals, not on at which store the payment was registered
   There's 5 payments not allocated to a rental so we need an additional query
   and totalize the sums per query*/
SELECT a.store_id, a.address, SUM(a.revenue) AS "Store Revenue"
FROM
(
SELECT	store.store_id, address.address, SUM(payment.amount) AS revenue
FROM	store
INNER JOIN address ON address.address_id = store.address_id
INNER JOIN inventory ON inventory.store_id = store.store_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY 1, 2
UNION ALL
SELECT	store.store_id, address.address, SUM(payment.amount) AS revenue
FROM	store 
INNER JOIN address ON address.address_id = store.address_id
INNER JOIN staff ON staff.store_id = store.store_id
INNER JOIN payment ON payment.staff_id = staff.staff_id
WHERE payment.rental_id IS NULL	
GROUP BY 1,2
) as a
GROUP BY 1,2;

/* 7g. Write a query to display for each store its store ID, city, and country. */
SELECT store.store_id, city.city, country.country
FROM store
INNER JOIN address ON address.address_id = store.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON country.country_id = city.country_id;


/* 7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.) */
SELECT	category.name, SUM(payment.amount) "Gross revenue"
FROM	category
INNER JOIN film_category ON film_category.category_id = category.category_id
INNER JOIN film ON film.film_id = film_category.film_id
INNER JOIN inventory ON inventory.film_id = film.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

/* 8a. In your new role as an executive, 
you would like to have an easy way of viewing the Top five genres by gross revenue. 
Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view. */
CREATE OR REPLACE VIEW revenue_top5 AS
SELECT	category.name, SUM(payment.amount) "Gross revenue"
FROM	category
INNER JOIN film_category ON film_category.category_id = category.category_id
INNER JOIN film ON film.film_id = film_category.film_id
INNER JOIN inventory ON inventory.film_id = film.film_id
INNER JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON payment.rental_id = rental.rental_id
GROUP BY 1
ORDER BY 2 DESC LIMIT 5;

/* 8b. How would you display the view that you created in 8a? */
SELECT	*
FROM	revenue_top5;

/* 8c. You find that you no longer need the view top_five_genres. Write a query to delete it. */
DROP VIEW IF EXISTS revenue_top5;
