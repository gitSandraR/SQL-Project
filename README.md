# DVD Rental Database -- Exploring data with SQL

### **OBJECTIVE**: to show some of SQL capabilities.

## 📂 Files and schema:
Database used for this demo is in a PostgreSQL ***dvdrental.tar*** file in the
repo.

SQL queries are in ***.sql*** files, and result sets are in ***.csv*** files with
the same names as queries.

To easily follow along the ER diagram is shown here:

![A diagram of a computer Description automatically
generated](./image1.png)

## 💡 Understanding DVD rental data:

Table ***film*** keeps the data about all the films in the DVD rental
store, while table **actor** has data about actors engaged in the
movies. There is many-to-many relationship between these two tables that
is represented here with ***film_actor*** table. Tabe ***category***
keeps different film categories (like drama, comedy, children...), and
it also has many-to-many relationship with **film** (in this case it
goes through ***film_category*** table). Table ***language*** contains
description of different movie languages, but there is only one language
that the films were made in (English), so it is irrelevant for any
analysis.

Table ***customer*** keeps data about all the customers, that reside on
different addresses, and that data can be found in ***address***,
***city*** and ***country*** tables.

There are two staff members and two stores which data is kept in tables
***staff*** and ***store***.

Finally, the more interesting tables are ***rental,*** ***inventory***
and ***payment***, through which customers and films are related. If the
movie was rented to a customer, a corresponding row exists in rentals
and inventory (if there hadn't been an inventory film could not have
been rented). There are some films present in inventory, but not rented
yet. If the payment was made a corresponding transaction is kept. Of
course, there are some rentals not paid yet (with a record in rentals
and nothing in payment table).

## 🔍 Exploring data with SQL:

🔷 **1\.** Let start with the query query that will answer the question: what
are the top 15 cities that generate the most revenue (or the 15 bottom
ones for example)?

```sql

SELECT ct.city,
       COUNT(c.customer_id) AS "# of customers",
       SUM(p.amount) AS "total amount"
FROM payment p
 INNER JOIN customer c ON c.customer_id = p.customer_id
 INNER JOIN address a ON a.address_id = c.address_id
 INNER JOIN city ct ON ct.city_id = a.city_id
GROUP BY ct.city_id
ORDER BY SUM(p.amount) DESC
LIMIT 15;

```

It shows the use of JOIN over several tables, and simple GROUP BY
clause. Number of customers and total amount paid is grouped for every
city. Results are then sorted by total amount in descending order and
limited to only 15 rows. This way the list shows the top 15 cities with
the most revenue.

Had the sorting been done in ascending order, we would have gotten the
bottom 15 cities -- that is with the lowest revenue.


🔷 **2\.** Here is the more basic query that shows the customers with overdue
items:

```sql

SELECT c.first_name,
       c.last_name,
       r.rental_date,
       r.return_date,
       r.return_date - r.rental_date AS "rented more than 7 days"
FROM customer c
 INNER JOIN rental r ON r.customer_id = c.customer_id
WHERE EXTRACT(day FROM r.return_date - r.rental_date) > 7;

```

The EXTRACT function retrieves subfields such as year or hour from
date/time values.


🔷 **3\.** The following query shows the most popular movies in Canada. It
demonstrates the use of subquery in WHERE clause. Usually operators IN
or EXISTS are used to link outer and subquery:

```sql

SELECT f.film_id, f.title, COUNT(r.rental_id) AS "# of rentals"
FROM film f
 INNER JOIN inventory i ON i.film_id = f.film_id
 INNER JOIN rental r ON r.inventory_id = i.inventory_id
WHERE r.customer_id IN
                    (SELECT c.customer_id
                     FROM customer c
                      INNER JOIN address a ON a.address_id = c.address_id
                      INNER JOIN city ct ON ct.city_id = a.city_id
                      INNER JOIN country ctr ON ctr.country_id = ct.country_id
                     WHERE ctr.country ILIKE 'Canada'
                    )
GROUP BY f.film_id, f.title
ORDER BY count(r.rental_id) DESC
LIMIT 20;

/* More straightforward/easier approach can give the same result
(with an extra detail):

SELECT f.film_id, f.title, ctr.country, COUNT(r.rental_id) AS "# of rentals"
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
```
The outer query gives a list of all titles and number of rentals per
title in descending order, and limited to first 20.
The subquery further limits the result to only those titles that were
rented to customers in Canada.

🔷 **4.** The following query shows the use of GROUP BY and HAVING clause. It
gives us a list of all customers with less than 20 rentals:

```sql

SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS "# of rentals"
FROM customer c
 INNER JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.first_name, c.last_name
HAVING COUNT(r.rental_id) < 20
ORDER BY COUNT(r.rental_id);

```

To limit the result set to a smaller number of rows we use condition in
WHERE clause. But with aggregate functions this condition is contained
within HAVING (that is: HAVING goes together with GROUP BY).

🔷 **5\.** This query shows a film category with the longest average duration.
It demonstrates the use of CTE (Common Table Expression):

```sql

WITH

        -- average film duration by category:
        Aver_Cat AS
                (
                 SELECT AVG(f.length) AS avg_length_in_minutes,
                        c.name AS film_category
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

--the next part combines the name of film category and its duration
--(that is the maximum duration of all categories):
SELECT avg_length_in_minutes AS "The longest average duration in minutes",
       film_category AS \"Film category\"
FROM Aver_Cat
 INNER JOIN MaxVal ON Aver_Cat.avg_length_in_minutes = MaxVal.maxim;
--WHERE avg_length_in_minutes = MaxVal.maxim
--WHERE clause is not needed since the MaxVal table has only one row

```

Common Table Expression or CTE is a temporary named result set that can
be referenced within a SELECT, INSERT, UPDATE, or DELETE statement.

In the example above, first CTE (Aver_Cat) gives us a list of all film
categories with an average film duration in minutes:

![A screenshot of a computer Description automatically
generated](./image2.png)

The second CTE (MaxVal) finds the maximal average duration. To do that
it references the first CTE. The result is shown:

![A screenshot of a computer Description automatically
generated](./image3.png)

Finally, the third query (main query) merges two CTEs, and shows this
maximal duration along with the name of corresponding category. The
result looks like this:

![A screenshot of a phone Description automatically
generated](./image4.png)

*Short note:* CTE begins with the word **WITH** than the name of CTE and
then the word **AS**. After that the SQL query that defines CTE is put
in brackets. If there is more than one CTE, the word WITH goes only once
at the beginning, and multiple CTEs are separated with comma. At the end
the main query is used to manipulate the results of these (temporary)
CTEs and create the final result. The main query can reference any of
the defined CTEs. One CTE can reference other CTE (but only the one
before it).

🔷 **6\.** The next query shows a list of all documentaries with ratings
explained. It shows a use case for CASE WHEN (multiple IF logic):

```sql

SELECT f.title,
       f.length AS "duration in minutes",
       f.rental_rate AS "rental rate",
       c.name AS "film category",
       CASE
           WHEN rating = 'NC-17' THEN 'NC-17: No One 17 and Under Admitted'
           WHEN rating = 'R' THEN 'Restricted -- Under 17 requires accompanying parent or adult guardian'
           WHEN rating = 'PG-13' THEN 'Parents strongly cautioned -- Some material may be inappropriate for children under 13'
           WHEN rating = 'G' THEN 'General audiences -- All ages admitted'
           WHEN rating = 'PG' THEN 'Parental guidance suggested -- Some material may not be suitable for children'
       END AS "film rating"
FROM film f
 INNER JOIN film_category fc ON fc.film_id = f.film_id
 INNER JOIN category c ON c.category_id = fc.category_id
WHERE c.name = 'Documentary'
ORDER BY title;

```
