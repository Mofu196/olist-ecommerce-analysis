#订单级经营KPI
WITH order_level AS (
  SELECT
    order_id,
    SUM(price) + MAX(freight_value) AS order_gmv
  FROM olist_clean
  GROUP BY order_id
)
SELECT
  COUNT(*) AS total_orders,
  ROUND(SUM(order_gmv), 2) AS total_gmv,
  ROUND(AVG(order_gmv), 2) AS aov
FROM order_level;

#复购率
WITH customer_orders AS (
  SELECT customer_unique_id, COUNT(DISTINCT order_id) AS order_count
  FROM olist_clean GROUP BY customer_unique_id
)
SELECT
  COUNT(*) AS total_customers,
  SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) AS repeat_customers,
  ROUND(SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS repurchase_rate
FROM customer_orders;

#迟到vs准时差评率
SELECT
  CASE WHEN is_late = 1 THEN '迟到' ELSE '准时' END AS delivery_status,
  COUNT(DISTINCT order_id) AS orders,
  ROUND(AVG(review_score), 2) AS avg_rating,
  ROUND(SUM(is_bad_review) * 100.0 / COUNT(*), 2) AS bad_review_rate
FROM olist_clean
WHERE review_score IS NOT NULL
GROUP BY delivery_status;

#月度GMV趋势
WITH order_level AS (
  SELECT
    order_id,
    DATE_FORMAT(MAX(order_purchase_timestamp), '%Y-%m') AS order_month,
    SUM(price) + MAX(freight_value) AS order_gmv
  FROM olist_clean
  GROUP BY order_id
)
SELECT
  order_month,
  COUNT(*) AS orders,
  ROUND(SUM(order_gmv), 2) AS gmv,
  ROUND(AVG(order_gmv), 2) AS aov
FROM order_level
WHERE order_month >= '2017-01'
GROUP BY order_month
ORDER BY order_month;