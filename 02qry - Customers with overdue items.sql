/* Customers with overdue items 
i.e. those who have rentals more than 7 days
*/

SELECT c.first_name, 
	c.last_name, 
	r.rental_date, 
	r.return_date,
	r.return_date - r.rental_date "rented more than 7 days"
FROM customer c
INNER JOIN rental r ON r.customer_id = c.customer_id
WHERE EXTRACT(day FROM r.return_date - r.rental_date) > 7;
