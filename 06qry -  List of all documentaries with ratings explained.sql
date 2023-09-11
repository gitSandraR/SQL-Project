/* List of all documentaries with ratings explained*/

SELECT f.title, 
	f.length AS "duration in minutes", 
	f.rental_rate AS "rental rate",
	c.name AS "film category",
	CASE
	WHEN rating = 'NC-17' THEN 'NC-17: No One 17 and Under Admitted'
	WHEN rating = 'R' THEN 'Restricted – Under 17 requires accompanying parent or adult guardian'
	WHEN rating = 'PG-13' THEN 'Parents strongly cautioned – Some material may be inappropriate for children under 13'
	WHEN rating = 'G' THEN 'General audiences – All ages admitted'
	WHEN rating = 'PG' THEN 'Parental guidance suggested – Some material may not be suitable for children '
	END AS "film rating"
FROM film f
INNER JOIN film_category fc ON fc.film_id = f.film_id
INNER JOIN category c ON c.category_id = fc.category_id
WHERE c.name = 'Documentary'
ORDER BY title;

