                       ---BASIC QUESTIONS---

select * from album
---Q1 : who is the senior most employee based on job title?
select * from employee
ORDER BY levels desc
LIMIT 1
 
---Q2 : Which countries have the most invoices?
select * from invoice

select count(*) as c, billing_country
from invoice
group by billing_country
order by c desc

---Q3 : What are top 3 values of total invoice
select total from invoice
order by total desc
limit 3

/*Q4 : Which city has the best customers? We would like to throw a promotional music festival in
the city we made the most money. Write a query that returns one city that has
the highest sum of invoice totals. Return both the city name and sum of all invoice totals.*/

select sum (total) as invoice_total, billing_city
from invoice
group by billing_city
order by invoice_total desc

/*Q5:Who is the best customer? the customer who has spent the most money will be declared the best customer.
write a query that returns the person who has spent the most money.*/

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
Join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1
                       --MODERATE QUESTION-- 

/*Q1:Write query to return the email, first name, last name, and genre of all rock music listeners.
return your list ordered alphabetically by email starting with A.*/

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name LIKE 'Rock'
)
order by email;

/*Q2:Lets invite the artists who have written the most rock music in our dataset.
write a query that returns the artist name and total track count of the top 10 rock bands.*/

select artist.artist_id, artist.name,count(artist.artist_id) as number_of_songs
from track 
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by number_of_songs desc
limit 10;


/*Q3:Return all the track names that have a song that have a song length longer than the avereage song length.
return the name and milliseconds for each track.
order by the song length with the longest songs listed first.*/

select name, milliseconds
from track
where milliseconds >(
	select AVG(milliseconds) as avg_track_length
	from track)
order by milliseconds desc;


                      ---ADVANCE QUESTIONS---

/*Q1:find how much amount spent by each customer on artists? 
write a query to return customer name, artist name and total spent.*/

/*steps: first find which artist has earned the most according to the invoicelines.now use this artist name to find which customer spent the most on this artist.
 for this query, you will need to use the invoice, invoiceline, track, customer, album and artist tables
 note this one is tricky because the total spent in the invoice table might not be on a single product, so
 you need to use the invoiceline table to find out how manyof each product was purchasedkand then multiply this by the price
 for each artist.*/

with best_selling_artist as(
select artist.artist_id as artist_id, artist.name as artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id = invoice_line.track_id
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
group by 1
order by 3 desc
limit 1
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,SUM(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id =i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 desc;

/*Q2:We want to find out the most popular music genre for each country.
we determine the most popular genre as the genre with the highest amount of purchases. 
write a query that returns each country along with the top genre.
for countries where the maximum number of purchases is shard return all genres.*/

with popular_genre as
(
select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as rowno
from invoice_line
join invoice on invoice.invoice_id = invoice_line.invoice_id
join customer on customer.customer_id = invoice.customer_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 2,3,4
order by 2 asc, 1 desc
)
select * from popular_genre where Rowno <=1

/*Q3:Write a query that determine the customer that has spent the most on music for each country.
write a query that returns the country along with the top customer and how much they spent.
for countries where the top amount spent is share, provide all customers who spent this amount.*/

/*step to solve: similar to the above question. there are two parts in question first find the
most spent on music for each country and second filter the data for respective customer.*/

with customer_with_country as(
		select customer.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
		row_number() over(partition by billing_country order by sum(total) desc) as rowno
		from invoice
		join customer on customer.customer_id = invoice.customer_id
		group by 1,2,3,4
		order by 4 asc,5 desc)
select * from customer_with_country where rowno<= 1










				 
