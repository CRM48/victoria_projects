-- Highest-spending customers in 2023.
SELECT c.customerid, c.f_name, c.l_name, SUM(s.amnt) AS total
FROM sales s
JOIN customer c ON c.customerid = s.customerid
JOIN dm_time t ON t.timeid = s.timeid
WHERE t.year = 2023
GROUP BY c.customerid, c.f_name, c.l_name
ORDER BY total DESC LIMIT 6;

-- Sales by year/country, including subtotals for each year and a grand total.
SELECT t.year, c.country, SUM(s.amnt) AS total
FROM sales s
JOIN customer c ON c.customerid = s.customerid
JOIN dm_time t ON t.timeid = s.timeid
WHERE t.year >= 2021
GROUP BY ROLLUP (t.year, c.country)
ORDER BY t.year, c.country;
