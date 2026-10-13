-- Monthly spending versus average monthly spending in active months of 2023.
WITH monthly_sales AS (
  SELECT c.city, t.year, EXTRACT(MONTH FROM t.orderdate)::integer AS month_num,
         TRIM(TO_CHAR(t.orderdate, 'Month')) AS month, SUM(s.amnt) AS monthly_sum
  FROM sales s JOIN customer c ON c.customerid = s.customerid
  JOIN dm_time t ON t.timeid = s.timeid
  WHERE t.year = 2023
  GROUP BY c.city, t.year, EXTRACT(MONTH FROM t.orderdate),
           TRIM(TO_CHAR(t.orderdate, 'Month'))
)
SELECT city, month, monthly_sum,
       ROUND(AVG(monthly_sum) OVER (PARTITION BY city, year), 2) AS yearly_average,
       ROUND(monthly_sum - AVG(monthly_sum) OVER (PARTITION BY city, year), 2) AS difference,
       COUNT(*) OVER (PARTITION BY city, year) AS months_with_sales
FROM monthly_sales ORDER BY city, month_num;
