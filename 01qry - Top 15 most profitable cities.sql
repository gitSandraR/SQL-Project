/* Top 15 most profitable cities
*/

SELECT ct.city, COUNT(c.customer_id) "# of customers", SUM(p.amount) "total amount"
FROM payment p
INNER JOIN customer c ON c.customer_id = p.customer_id
INNER JOIN address a ON a.address_id = c.address_id
INNER JOIN city ct ON ct.city_id = a.city_id
GROUP BY ct.city_id
ORDER BY SUM(p.amount) DESC
LIMIT 15;


/* Similarly: the 15 least profitable cities:

SELECT ct.city, COUNT(c.customer_id) "# of customers", SUM(p.amount) "total amount"
FROM payment p
INNER JOIN customer c ON c.customer_id = p.customer_id
INNER JOIN address a ON a.address_id = c.address_id
INNER JOIN city ct ON ct.city_id = a.city_id
GROUP BY ct.city_id
ORDER BY SUM(p.amount)
LIMIT 15;

*/