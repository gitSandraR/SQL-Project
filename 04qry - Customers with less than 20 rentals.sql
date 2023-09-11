/* List of all customers with less than 20 rentals */

SELECT c.first_name, c.last_name, COUNT(r.rental_id) "# of rentals"
FROM customer c
INNER JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
HAVING COUNT(r.rental_id) < 20
ORDER BY COUNT(r.rental_id)
