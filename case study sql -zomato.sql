use zomato
select * from delivery_partner$
select * from food$
select * from menu$
select * from order_details$
select * from orders$
select * from restaurants$
select * from users$
-------------------------------------
@ person who never ordered from zomato platform

select * from orders$
select * from users$

SELECT name 
FROM users$
WHERE user_id NOT IN (SELECT user_id FROM orders$)


 ------------------------------------
@ Average prie of the food items overall the restaurants

select * from menu$
select * from food$

SELECT f.f_name, AVG(m.price) AS average_price
FROM menu$ m
JOIN food$ f ON m.f_id = f.f_id
GROUP BY f.f_name  
ORDER BY average_price DESC;

---------------------------------------

@ Top restaurant in terms of number of order for the given month
---june
SELECT TOP 1 r.r_name, COUNT(*) AS [month_count]
FROM orders$ o
JOIN restaurants$ r ON o.r_id = r.r_id
WHERE DATENAME(month, [date]) = 'June'
GROUP BY r.r_id, r.r_name
ORDER BY COUNT(*) DESC;

---may
SELECT TOP 1 r.r_name, COUNT(*) AS [month_count]
FROM orders$ o
JOIN restaurants$ r ON o.r_id = r.r_id
WHERE DATENAME(month, [date]) = 'may'
GROUP BY r.r_id, r.r_name
ORDER BY COUNT(*) DESC;

---july
SELECT TOP 1 r.r_name, COUNT(*) AS [month_count]
FROM orders$ o
JOIN restaurants$ r ON o.r_id = r.r_id
WHERE DATENAME(month, [date]) = 'july'
GROUP BY r.r_id, r.r_name
ORDER BY COUNT(*) DESC;


 ------------------------------------
 @ restaurants with monthly sales > 500 for

SELECT o.order_id, r.r_name, SUM(o.amount) AS revenue
FROM orders$ o
JOIN restaurants$ r ON r.r_id = o.r_id
WHERE DATENAME(month, o.[date]) = 'June'
GROUP BY o.order_id, r.r_name
HAVING SUM(o.amount) > 500;


 ------------------------------------
 @ show all order with order details for a perticular customer in a perticular date range

 SELECT o.order_id,r.r_name,f.f_name
FROM orders$ o
JOIN restaurants$ r ON o.r_id = r.r_id
join order_details$ od on o.order_id=od.order_id
join food$ f on f.f_id=od.f_id
WHERE o.user_id = (SELECT user_id FROM users$ WHERE name LIKE 'ankit')
  AND o.date > '2020-06-10' 
  AND o.date < '2022-07-10';

 SELECT o.order_id,r.r_name,f.f_name
FROM orders$ o
JOIN restaurants$ r ON o.r_id = r.r_id
join order_details$ od on o.order_id=od.order_id
join food$ f on f.f_id=od.f_id
WHERE o.user_id = (SELECT user_id FROM users$ WHERE name LIKE 'nitish')
  AND o.date > '2020-06-10' 
  AND o.date < '2022-07-10';


 ------------------------------------
 @ get the name of the restaurant where no of customer repeated alot(loyal costomer)

SELECT TOP 1 r.r_name, COUNT(*) as loyal_customer_count
FROM (
    SELECT r_id, user_id, COUNT(*) as visits
    FROM orders$
    GROUP BY r_id, user_id
    HAVING COUNT(*) > 1
) t
JOIN restaurants$ r ON r.r_id = t.r_id
GROUP BY t.r_id, r.r_name
ORDER BY COUNT(*) DESC;


------------------------------------
@ Month over month revenue growth for all restaurant

WITH MonthlyRevenue AS (
    SELECT DATENAME(month, [date]) AS month_name,
           DATEPART(month, [date]) AS month_number,
           SUM(amount) AS revenue
    FROM orders$
    GROUP BY DATENAME(month, [date]), DATEPART(month, [date])
)
SELECT 
    month_name,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY month_number) AS prev_month_revenue,
    ((revenue - LAG(revenue, 1) OVER (ORDER BY month_number)) / LAG(revenue, 1) OVER (ORDER BY month_number)) * 100 AS revenue_growth
FROM MonthlyRevenue
ORDER BY month_number;


------------------------------------
@ customer--> favorite food


WITH temp AS (
    SELECT o.user_id, od.f_id, COUNT(*) AS frequency
    FROM orders$ o
    JOIN order_details$ od ON o.order_id = od.order_id
    GROUP BY o.user_id, od.f_id
)

SELECT u.name, f.f_name,t1.frequency
FROM temp t1
JOIN users$ u ON u.user_id = t1.user_id
JOIN food$ f ON f.f_id = t1.f_id
WHERE t1.frequency = (
    SELECT MAX(t2.frequency)
    FROM temp t2
    WHERE t2.user_id = t1.user_id
);



-----------------------------------ad


