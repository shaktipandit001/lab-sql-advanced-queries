use sakila;
-- 1. List each pair of actors that have worked together.

--  list actors and the films they've acted on
select fa.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name, fa.film_id
from sakila.film_actor fa
join sakila.actor a
on fa.actor_id = a.actor_id;

--  Create two Common Table Expressions (CTE) with the previous querry and join them after
with cte_colleague_actors_1 as (
	select fa.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name, fa.film_id
	from sakila.film_actor fa
	join sakila.actor a
	on fa.actor_id = a.actor_id
), cte_colleague_actors_2 as (
	select fa.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name, fa.film_id
	from sakila.film_actor fa
	join sakila.actor a
	on fa.actor_id = a.actor_id
)
select ct1.film_id, ct1.actor_id as actor_id_1, ct1.actor_name as actor_name_1, ct2.actor_id as actor_id_2, ct2.actor_name as actor_name_2
from cte_colleague_actors_1 ct1
join cte_colleague_actors_2 ct2
on ct1.film_id = ct2.film_id and ct1.actor_id > ct2.actor_id;
 
-- 2. For each film, list actor that has acted in more films.

--  List all the actor and count how many films they've been on
select actor_id, count(film_id) as film_count
from sakila.film_actor
group by actor_id;

--  list actors and the films they've acted on
select fa.film_id, f.title, fa.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name
from sakila.film_actor fa
join sakila.film f
on fa.film_id = f.film_id
join sakila.actor a
on fa.actor_id = a.actor_id;

-- Join the previous two querries
with cte_actor_count as (
	select actor_id, count(film_id) as film_count
	from sakila.film_actor
	group by actor_id
), cte_film_actors as (
	select fa.film_id, f.title, fa.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name
	from sakila.film_actor fa
	join sakila.film f
	on fa.film_id = f.film_id
	join sakila.actor a
	on fa.actor_id = a.actor_id
)
select ct2.film_id, ct2.title, ct1.actor_id, ct2.actor_name, ct1.film_count
from  cte_actor_count ct1
join cte_film_actors ct2
on ct1.actor_id = ct2.actor_id
order by ct2.film_id;

--  Create a view with the previous querry
create view film_actor_film_count as 
with cte_actor_count as (
	select actor_id, count(film_id) as film_count
	from sakila.film_actor
	group by actor_id
), cte_film_actors as (
	select fa.film_id, f.title, fa.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name
	from sakila.film_actor fa
	join sakila.film f
	on fa.film_id = f.film_id
	join sakila.actor a
	on fa.actor_id = a.actor_id
)
select ct2.film_id, ct2.title, ct1.actor_id, ct2.actor_name, ct1.film_count
from  cte_actor_count ct1
join cte_film_actors ct2
on ct1.actor_id = ct2.actor_id
order by ct2.film_id;

--  Select the max_film_count per film
select film_id, max(film_count) as max_film_count from film_actor_film_count
group by film_id;

--  Join the view with the step 5 querry in a Common Table Expressions (CTE):
with cte_max_film_count as (
	select film_id, max(film_count) as max_film_count from film_actor_film_count
	group by film_id
)
select cte.film_id, v.title, v.actor_id, v.actor_name, cte.max_film_count
from cte_max_film_count cte
join film_actor_film_count v
on cte.film_id = v.film_id and cte.max_film_count = v.film_count
order by cte.film_id;