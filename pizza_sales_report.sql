#Retrieve the total number of orders placed.
select 
	count(order_details_id) as "Total number of orders placed"
from order_details;

#Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS 'Total Sales'
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
#Identify the highest-priced pizza.
SELECT 
    pizzas.price, pizza_types.name
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

#Identify the most common pizza size ordered
SELECT 
    pizzas.size,
    COUNT(order_details.quantity) AS `Most Common Pizza Size`
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY `Most Common Pizza Size` DESC limit 1;

#List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name, SUM(order_details.quantity) as quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS 'Total Quantity'
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY 'Total Quantity' DESC;

#Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), 
    COUNT(order_id) as "Order ID"
FROM
    orders
GROUP BY HOUR(order_time);

#Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

#Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    round(AVG(quantity))
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;


#Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(pizzas.price * order_details.quantity) AS 'revenue'
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue
LIMIT 3;

#Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    SUM(order_details.quantity * pizzas.price) / total_sales * 100 AS revenue_percentage
FROM 
    pizza_types
JOIN 
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN 
    order_details ON order_details.pizza_id = pizzas.pizza_id
JOIN 
    (SELECT 
         ROUND(SUM(order_details.quantity * pizzas.price), 2) AS total_sales
     FROM 
         order_details
     JOIN 
         pizzas ON pizzas.pizza_id = order_details.pizza_id) AS total_sales_table ON 1=1
GROUP BY 
    pizza_types.category, total_sales
ORDER BY 
    revenue_percentage DESC;

#Analyze the cumulative revenue generated over time.
SELECT 
    order_date,
    round(SUM(revenue) OVER (ORDER BY order_date),2) AS cum_revenue
FROM 
    (SELECT 
         orders.order_date, 
         SUM(order_details.order_details_id * pizzas.price) as revenue
     FROM 
         order_details 
     JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id
     JOIN orders ON orders.order_id = order_details.order_id
     GROUP BY 
         orders.order_date
    ) AS sales;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category. 
select name, revenue from 
(select category,name, revenue,
rank() over(partition by category order by revenue desc) as rn
from 
(select pizza_types.category, pizza_types.name, sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <=3;

