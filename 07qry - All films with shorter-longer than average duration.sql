/* All the movies with shorter/longer than average duration */

--list of all films with average film duration per film_category:
WITH
		Aver_per_Category AS
		(

			SELECT  AVG(f.length) OVER(PARTITION BY c.name) AS avg_length_per_category_in_minutes, c.name AS film_category, f.length, f.title
			FROM film f
				INNER JOIN film_category fc ON f.film_id = fc.film_id
				INNER JOIN category c ON fc.category_id = c.category_id
			ORDER BY c.name, f.title
		)

--main query: description added for readability
--is movie longer or shorter than average duration in it's category:
SELECT Aver_per_Category.*,
		CASE
			WHEN avg_length_per_category_in_minutes > length THEN 'Shorter than average in this category'
			WHEN avg_length_per_category_in_minutes < length THEN 'Longer than average in this category'
			ELSE 'Average length in this category'
		END AS Longer_Shorter
FROM Aver_per_Category;