/* Film category with the longest average duration */

WITH 
	-- average film duration by category:
	Aver_Cat AS
	(
		SELECT  AVG(f.length) AS avg_length_in_minutes, c.name AS film_category
		FROM film f
		INNER JOIN film_category fc ON f.film_id = fc.film_id
		INNER JOIN category c ON fc.category_id = c.category_id
		GROUP BY c.name
		ORDER BY c.name
	),
		
	-- of all the average durations per category which one is the biggest:
	MaxVal AS
	(
		SELECT MAX(avg_length_in_minutes) As maxim
		FROM Aver_Cat
	)
	
--this part combines the name of film category and its duration 
--(that is the maximum duration of all categories):
SELECT avg_length_in_minutes AS "The longest average duration in minutes", film_category AS "Film category"
FROM Aver_Cat
INNER JOIN MaxVal ON Aver_Cat.avg_length_in_minutes = MaxVal.maxim;
--WHERE avg_length_in_minutes = MaxVal.maxim
--WHERE clause is not needed since the MaxVal table has only one row



