/* The most popular movies in Canada, with subquery

The outer query gives a list of all titles and number of rentals per title
in descending order, and limited to first 20
The subquery further limits the result to only those titles that were rented to
customers in Canada
*/

SELECT f.film_id, f.title, COUNT(r.rental_id) "# of rentals"
FROM film f
INNER JOIN inventory i ON i.film_id = f.film_id
INNER JOIN rental r ON r.inventory_id = i.inventory_id
WHERE r.customer_id IN (SELECT c.customer_id
					    FROM customer c
					    INNER JOIN address a ON a.address_id = c.address_id
					    INNER JOIN city ct ON ct.city_id = a.city_id
					    INNER JOIN country ctr ON ctr.country_id = ct.country_id
					    WHERE ctr.country ILIKE 'Canada'
					   )
GROUP BY f.film_id, f.title
ORDER BY count(r.rental_id) DESC
LIMIT 20;

/* More straighforward/easier approach can give the same result
   (with an extra detail):

SELECT f.film_id, f.title, ctr.country, COUNT(r.rental_id) "# of rentals"
FROM film f
	INNER JOIN inventory i ON i.film_id = f.film_id
	INNER JOIN rental r ON r.inventory_id = i.inventory_id
	INNER JOIN customer c ON c.customer_id = r.customer_id
	INNER JOIN address a ON a.address_id = c.address_id
	INNER JOIN city ct ON ct.city_id = a.city_id
	INNER JOIN country ctr ON ctr.country_id = ct.country_id
WHERE ctr.country ILIKE 'Canada'					   
GROUP BY f.film_id, f.title, ctr.country
ORDER BY count(r.rental_id) DESC
LIMIT 20;

*/

