-- pizzahut project 

-- BASIC:
-- Q 1. Retrieve the total number of orders placed.
select count(order_id) as total_orders from orders;


-- Q 2. Calculate the total revenue generated from pizza sales.
select 
round(sum(order_details.quantity * pizzas.price), 2) as total_sales
from
order_details join pizzas on order_details.pizza_id = pizzas.pizza_id;


-- Q 3. Identify the highest-priced pizza.
select pizza_types.name, pizzas.price
from 
pizza_types join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc 
limit 1;


-- Q 4. Identify the most common pizza size ordered.
select pizzas.size, count(order_details.quantity)
from 
pizzas join order_details on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by count(order_details.quantity) desc
limit 1;


-- Q 5. List the top 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(order_details.quantity)
from
pizza_types join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by sum(order_details.quantity) desc
limit 5;

-- INTERMEDIATE
-- Q.6 Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(order_details.quantity)
from pizza_types
join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by sum(order_details.quantity) desc;


-- Q.7 Determine the distribution of orders by hour of the day.
select hour(order_time) as hours, count(order_id) as order_count from orders
group by hour(order_time);


-- Q.8 Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;


-- Q.9 Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity), 0) as avg_pizza
from (select orders.order_date, sum(order_details.quantity) as quantity 
from orders
join order_details on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;


-- Q.10 Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, round(sum(order_details.quantity * pizzas.price) as revenue 
from pizza_types 
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by revenue desc
limit 3;

-- ADVANCED
-- Q.11 Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    round(SUM(order_details.quantity * pizzas.price) / (SELECT 
            ROUND(SUM(order_details.quantity * pizzas.price),
                        2) AS total_sales
        FROM
            order_details
                JOIN
            pizzas ON pizzas.pizza_id = order_details.pizza_id) *100, 2)  AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Q.12 Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue
from 
(select orders.order_date, round(sum(order_details.quantity * pizzas.price), 2) as revenue
from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


-- Q.13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue 
from 
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn
from 
(select pizza_types.category, pizza_types.name, sum((order_details.quantity) * pizzas.price) as revenue
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;






