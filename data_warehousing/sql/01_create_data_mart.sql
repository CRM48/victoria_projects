-- Run after loading data/bookstore.sql into an empty PostgreSQL database.
CREATE TABLE dm_time AS
SELECT ROW_NUMBER() OVER (ORDER BY orderdate)::integer AS timeid,
       orderdate,
       TRIM(TO_CHAR(orderdate, 'Day')) AS dayofweek,
       TRIM(TO_CHAR(orderdate, 'Month')) AS month,
       EXTRACT(YEAR FROM orderdate)::integer AS year
FROM (SELECT DISTINCT orderdate FROM cust_order) dates;

ALTER TABLE dm_time ADD PRIMARY KEY (timeid);
CREATE UNIQUE INDEX dm_time_orderdate_idx ON dm_time (orderdate);

CREATE TABLE sales AS
SELECT co.customerid, t.timeid, od.isbn,
       SUM(od.quantity * b.price) AS amnt
FROM cust_order co
JOIN order_detail od ON od.orderid = co.orderid
JOIN book b ON b.isbn = od.isbn
JOIN dm_time t ON t.orderdate = co.orderdate
GROUP BY co.customerid, t.timeid, od.isbn;

CREATE INDEX sales_customer_idx ON sales (customerid);
CREATE INDEX sales_time_idx ON sales (timeid);
