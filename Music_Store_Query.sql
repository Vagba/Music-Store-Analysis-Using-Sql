#Q1: Who is the senior most employee based on job title?

select first_name,last_name,title,levels
from employee
order by levels desc
limit 1;

#Q2: Which countries have the most Invoices?

select billing_country,count(invoice_id) as Total_Invoices
from invoice
group by 1
order by count(invoice_id) desc
limit 10;

#Q3: What are top 3 values of total invoice?

select invoice_id,round(sum(total),2) as Total_Amount
from invoice 
group by 1
order by 2 desc
limit 3;

#Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money.

select billing_city as City_Name, round(sum(total),2) as Total_Amount
from invoice
group by 1
order by 2 desc
limit 1;

#Who is the best customer? The customer who has spent the most money will be declared the best customer.

select c.customer_id,concat(c.first_name,'',c.last_name) as Customer_Name,round(sum(i.total),2) as Total_Amount
from customer c 
join invoice i on i.customer_id = c.customer_id
group by 1,2
order by 3 desc
limit 1;

#Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners.

select distinct c.customer_id,concat(c.first_name,'',c.last_name) as Customer_Name,c.email,g.genre_id,g.name as Genre_Name
from customer c 
join invoice i on i.customer_id = c.customer_id
join invoice_line l on l.invoice_id =i.invoice_id
join track t on t.track_id = l.track_id
join genre g on g.genre_id = t.genre_id
where g.genre_id = 1
order by c.email asc;

#Q7: Let's invite the artists who have written the most rock music in our dataset.

select a.name as Artist_Name, count(t.track_id) as Total_Tracks
from artist a
join album2 al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join genre g on g.genre_id = t.genre_id
where g.genre_id = 1
group by 1
order by 2 desc
limit 10;

#Q8: Return all the track names that have a song length longer than the average song length.

select name as Track_Name, milliseconds
from track
where milliseconds > (select avg(milliseconds) as avg_track
						from track)
order by milliseconds desc;

#Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

WITH Best_Selling_Artist AS (
  SELECT
    artist.artist_id,
    artist.name AS Artist_Name,
    SUM(invoice_line.unit_price * invoice_line.quantity) AS Total_Sales
  FROM
    invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album2 ON album2.album_id = track.album_id
    JOIN artist ON artist.artist_id = album2.artist_id
  GROUP BY 1, 2
  ORDER BY 3 DESC
  LIMIT 1
)

SELECT
  c.customer_id,
  CONCAT(c.first_name, '', c.last_name) AS Customer_Name,
  bsa.Artist_Name,
  ROUND(SUM(il.unit_price * il.quantity), 2) AS Total_Spent
FROM
  customer c
  JOIN invoice i ON i.customer_id = c.customer_id
  JOIN invoice_line il ON il.invoice_id = i.invoice_id
  JOIN track t ON t.track_id = il.track_id
  JOIN album2 alb ON alb.album_id = t.album_id
  JOIN Best_Selling_Artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

#Q10: We want to find out the most popular music Genre for each country.

WITH Most_Popular_Genre AS (
  SELECT
    customer.country AS Country,
    COUNT(invoice_line.quantity) AS Purchases,
    genre.genre_id AS Genre_ID,
    genre.name AS Genre_Name,
    ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS rn
  FROM
    customer
    JOIN invoice ON invoice.customer_id = customer.customer_id
    JOIN invoice_line ON invoice_line.invoice_id = invoice.invoice_id  -- Fixed typo here
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
  GROUP BY Country, genre.genre_id, genre.name
  ORDER BY Country, Purchases DESC
)

SELECT
  Country,
  Purchases,
  Genre_ID,
  Genre_Name
FROM
  Most_Popular_Genre
  where rn <=1;

#Q11: Write a query that determines the customer that has spent the most on music for each country.

WITH Best_Customers AS (
    SELECT  
        c.customer_id as Customer_id,
        CONCAT(c.first_name, '', c.last_name) AS Customer_Name,
        c.country AS Country,
        round(sum(i.total),2) as Total_Spent,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY SUM(i.total) DESC) AS rn
    FROM 
        customer c
        JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY 1, 2, 3
    ORDER BY 4 DESC
)

SELECT 
    Customer_id,
    Customer_Name,
    Country,
    Total_Spent
FROM 
    Best_Customers
WHERE 
    rn <= 1
order by 4 desc;
