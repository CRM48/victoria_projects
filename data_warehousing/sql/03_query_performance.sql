-- Materialized alternatives for exploring aggregation and join costs.
-- Run these definitions once, then compare EXPLAIN ANALYZE plans.
CREATE MATERIALIZED VIEW view1 AS
SELECT s.customerid, c.f_name, c.l_name, t.year, s.isbn, s.amnt
FROM sales s JOIN customer c ON c.customerid = s.customerid
JOIN dm_time t ON t.timeid = s.timeid;

CREATE MATERIALIZED VIEW view2 AS
SELECT s.customerid, c.f_name, c.l_name, c.country, t.year, SUM(s.amnt) AS sum
FROM sales s JOIN customer c ON c.customerid = s.customerid
JOIN dm_time t ON t.timeid = s.timeid
GROUP BY s.customerid, c.f_name, c.l_name, c.country, t.year;

CREATE MATERIALIZED VIEW view3 AS
SELECT c.district, t.year, SUM(s.amnt) AS sum
FROM sales s JOIN customer c ON c.customerid = s.customerid
JOIN dm_time t ON t.timeid = s.timeid
GROUP BY c.district, t.year;

-- Benchmark operational tables versus aggregated materialized views.
VACUUM ANALYZE;

EXPLAIN ANALYZE
SELECT c.customerid, c.f_name, c.l_name, SUM(od.quantity * b.price) AS total
FROM cust_order co JOIN order_detail od ON od.orderid = co.orderid
JOIN customer c ON c.customerid = co.customerid
JOIN book b ON b.isbn = od.isbn
WHERE EXTRACT(YEAR FROM co.orderdate) = 2023
GROUP BY c.customerid, c.f_name, c.l_name ORDER BY total DESC LIMIT 6;

EXPLAIN ANALYZE
SELECT customerid, f_name, l_name, SUM(amnt) AS total
FROM view1 WHERE year = 2023
GROUP BY customerid, f_name, l_name ORDER BY total DESC LIMIT 6;

EXPLAIN ANALYZE
SELECT customerid, f_name, l_name, sum AS total
FROM view2 WHERE year = 2023 ORDER BY total DESC LIMIT 6;

-- Compare two equivalent formulations of the data mart query.
EXPLAIN ANALYZE
SELECT c.customerid, c.f_name, c.l_name, SUM(s.amnt) AS total
FROM sales s JOIN customer c ON c.customerid = s.customerid
JOIN dm_time t ON t.timeid = s.timeid WHERE t.year = 2023
GROUP BY c.customerid, c.f_name, c.l_name ORDER BY total DESC LIMIT 6;

EXPLAIN ANALYZE
SELECT c.customerid, c.f_name, c.l_name, q.total
FROM (SELECT s.customerid, SUM(s.amnt) AS total
      FROM sales s JOIN dm_time t ON t.timeid = s.timeid
      WHERE t.year = 2023 GROUP BY s.customerid
      ORDER BY total DESC LIMIT 6) q
JOIN customer c ON c.customerid = q.customerid ORDER BY q.total DESC;

-- Compare country totals using base and preaggregated data.
EXPLAIN ANALYZE
SELECT c.country, SUM(s.amnt) AS total
FROM sales s JOIN customer c ON c.customerid = s.customerid
GROUP BY c.country ORDER BY total DESC LIMIT 1;

EXPLAIN ANALYZE
SELECT country, SUM(sum) AS total
FROM view2 GROUP BY country ORDER BY total DESC LIMIT 1;

-- Assumes districts belong to exactly one country in this dataset.
EXPLAIN ANALYZE
SELECT c.country, SUM(v.sum) AS total
FROM view3 v JOIN (SELECT DISTINCT district, country FROM customer) c
ON c.district = v.district GROUP BY c.country ORDER BY total DESC LIMIT 1;
