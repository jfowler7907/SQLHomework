USE sakila;
SELECT * FROM actor;
#1A Display first and last names of all actors from the actors table
SELECT first_name, last_name FROM actor;

#1b Display first and last names of each actor in a single column in upper case. Name the column Actor Name
SELECT CONCAT (`first_name`," ",`last_name`) AS Actor_Name FROM actor;

#2a Find the ID number, first name and lst name of an actor, of whom you know only the first name,"Joe"
SELECT actor_id, first_name, last_name FROM actor 
WHERE first_name = "Joe";

#2b Find all actors whose last name contain the letters GEN
SELECT * FROM actor
WHERE last_name LIKE "%GEN%";

#2c Find all actors whose last names contain the letters LI. Order the rows by last_name and first_name in that order
SELECT * FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

#2d Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country
WHERE country IN("Afghanistan", "Bangladesh", "China");

#3a Create column in actor table called description use datatype blob
ALTER TABLE actor
ADD description blob;
SELECT * FROM actor;

#3b Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;
SELECT * FROM actor;

#4a List the last names of actors, as well as how many actors have that last name
SELECT COUNT(last_name),last_name
FROM actor
GROUP BY last_name;

#4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT COUNT(last_name),last_name
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >2
ORDER BY COUNT(last_name) DESC;

#4c The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
SELECT * FROM actor
WHERE actor_id=172;

UPDATE actor
SET first_name = "HARPO"
WHERE actor_id = 172;

SELECT * FROM actor
WHERE actor_id = 172;

#4d Perhaps we were too hasty in changing GROUCHO to HARPO. 
  #It turns out that GROUCHO was the correct name after all! 
  #In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.

UPDATE actor
SET first_name = "GROUCHO"
WHERE actor_id = 172;

SELECT * FROM actor
WHERE actor_id = 172;

#5a You cannot locate the schema of the address table. Which query would you use to re-create it?
  #Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
  
SHOW CREATE TABLE address;
CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

#6a Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
  #Note: Inner Join. address_id is a common identifier between tables

SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address
ON staff.address_id = address.address_id;

#6b Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
  #Both tables have staff_id as a common identifier
  
    #find sum of staff_id1,2
    SELECT SUM(amount)
    FROM payment
    WHERE staff_id=2;

SELECT staff.staff_id, staff.first_name, staff.last_name, SUM(amount)
FROM staff
INNER JOIN payment
ON staff.staff_id = payment.staff_id
WHERE payment.payment_date LIKE '2005-08%'
GROUP BY payment.staff_id;

#6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT film.film_id, film.title, COUNT(actor_id)
FROM film
INNER JOIN film_actor
ON film.film_id = film_actor.film_id
GROUP BY film_id;

#6d How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT film.film_id, film.title, COUNT(store_id)
FROM film
INNER JOIN inventory
ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible";

#6e Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:

SELECT customer.first_name, customer.last_name, SUM(amount)
FROM customer
INNER JOIN payment
ON customer.customer_id = payment.customer_id
GROUP BY last_name
ORDER BY last_name ASC;

#7a The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
  #As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
  #Use subqueries to display the titles of movies starting with the letters K and Q whose language is English
SELECT title, language_id
FROM film
WHERE title IN
(SELECT title
FROM film
WHERE language_id = 1
AND title LIKE "K%" 
OR title LIKE "Q%");

#7b Use subqueries to display all actors who appear in the film Alone Trip.
  #Run film table, Run film_actor table
SELECT actor_id, first_name, last_name 
FROM actor
WHERE actor_id IN 
	(SELECT actor_id
	FROM film_actor
	WHERE film_id = 
		(SELECT film_id
		FROM film
		WHERE title ="Alone Trip"));

#7c You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
   #Use joins to retrieve this information.
SELECT customer.first_name, customer.last_name, customer.email
FROM city
INNER JOIN address
ON city.city_id=address.city_id
INNER JOIN customer
ON address.address_id=customer.address_id
WHERE country_id=20;

#7d  Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
  #Identify all movies categorized as family films.
SELECT film.title, category.name
FROM film
INNER JOIN film_category
ON film.film_id
INNER JOIN category
ON category.category_id
WHERE category.name = "Family";

#7e Display the most frequently rented movies in descending order.
SELECT film.title, count(rental.rental_id)
FROM rental
INNER JOIN inventory
ON rental.inventory_id=inventory.inventory_id
INNER JOIN film
ON inventory.film_id=film.film_id
GROUP BY film.title
ORDER BY count(rental.rental_id) DESC;


#7f Write a query to display how much business, in dollars, each store brought in.
SELECT staff.store_id, SUM(payment.amount)
FROM staff
INNER JOIN payment
ON staff.staff_id = payment.staff_id
GROUP BY staff.store_id;

#7g Write a query to display for each store its store ID, city, and country.
SELECT store.store_id, city.city, country.country
FROM country
INNER JOIN city
ON city.country_id=country.country_id
INNER JOIN address
ON address.city_id=city.city_id
INNER JOIN store
ON store.address_id=address.address_id
GROUP BY city.city;

#7h List the top five genres in gross revenue in descending order. 
  #(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT count(payment.rental_id), category.name, sum(payment.amount)
FROM category
INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN inventory
ON film_category.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY category.name 
ORDER BY payment.amount DESC
LIMIT 5;


#8a In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
  #Use the solution from the problem above to create a view. 
  #If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW `Gross_Revenue` AS 
SELECT count(payment.rental_id), category.name, sum(payment.amount)
FROM category
INNER JOIN film_category
ON category.category_id = film_category.category_id
INNER JOIN inventory
ON film_category.film_id = inventory.film_id
INNER JOIN rental
ON inventory.inventory_id = rental.inventory_id
INNER JOIN payment
ON rental.rental_id = payment.rental_id
GROUP BY category.name 
ORDER BY payment.amount DESC
LIMIT 5;
  
#8b. How would you display the view that you created in 8a?  
SHOW CREATE VIEW `gross_revenue`

#8c You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW gross_revenue;

