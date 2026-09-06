-- =====================================================================
-- Star schema build
-- Rules enforced here are defined in docs/02_metric_definitions.md
-- Raw tables are never modified.
-- =====================================================================

-- ---------- DIMENSIONS ------------------------------------------------

-- One row per real customer. customer_unique_id is the person;
-- customer_id is per-order (see Data Quality Report §1).
-- Location taken from the customer's most recent order.
CREATE OR REPLACE TABLE dim_customer AS
WITH ranked AS (
    SELECT
        c.customer_unique_id,
        c.customer_state,
        c.customer_city,
        c.customer_zip_code_prefix,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp DESC
        ) AS rn
    FROM raw_customers c
    JOIN raw_orders o ON c.customer_id = o.customer_id
)
SELECT customer_unique_id, customer_state, customer_city, customer_zip_code_prefix
FROM ranked
WHERE rn = 1;

CREATE OR REPLACE TABLE dim_seller AS
SELECT seller_id, seller_state, seller_city, seller_zip_code_prefix
FROM raw_sellers;

-- Category names translated to English; untranslated rows kept as 'unknown'
CREATE OR REPLACE TABLE dim_product AS
SELECT
    p.product_id,
    COALESCE(t.product_category_name_english,
             p.product_category_name,
             'unknown') AS category,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM raw_products p
LEFT JOIN raw_categories t
       ON p.product_category_name = t.product_category_name;

CREATE OR REPLACE TABLE dim_date AS
SELECT
    d::DATE                              AS date_key,
    EXTRACT(year    FROM d)              AS year,
    EXTRACT(month   FROM d)              AS month,
    EXTRACT(quarter FROM d)              AS quarter,
    date_trunc('month', d)::DATE         AS month_start,
    EXTRACT(dow FROM d)                  AS day_of_week,
    EXTRACT(dow FROM d) IN (0, 6)        AS is_weekend
FROM generate_series(DATE '2016-09-01', DATE '2018-10-31', INTERVAL 1 DAY) AS t(d);


-- ---------- STAGING ---------------------------------------------------

-- Valid orders only. Every condition maps to a rule in the metric doc.
CREATE OR REPLACE TABLE stg_valid_orders AS
SELECT o.*
FROM raw_orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp >= DATE '2017-01-01'
  AND o.order_purchase_timestamp <  DATE '2018-09-01'
  AND (o.order_delivered_carrier_date IS NULL
       OR o.order_delivered_customer_date >= o.order_delivered_carrier_date)
  AND EXISTS (SELECT 1 FROM raw_order_items i WHERE i.order_id = o.order_id);

-- Revenue from items, never from payments (payments split across
-- installment rows and would double-count).
CREATE OR REPLACE TABLE stg_order_agg AS
SELECT
    order_id,
    SUM(price)                    AS items_price,
    SUM(freight_value)            AS freight,
    SUM(price + freight_value)    AS order_revenue,
    COUNT(*)                      AS item_count,
    COUNT(DISTINCT seller_id)     AS seller_count
FROM raw_order_items
GROUP BY order_id;

-- Earliest review per order (rule and rationale in metric doc)
CREATE OR REPLACE TABLE stg_order_review AS
SELECT order_id, review_score
FROM (
    SELECT order_id, review_score,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY review_creation_date, review_id
           ) AS rn
    FROM raw_reviews
)
WHERE rn = 1;


-- ---------- FACTS -----------------------------------------------------

-- Grain: one row per valid order
CREATE OR REPLACE TABLE fact_orders AS
WITH base AS (
    SELECT
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp,
        o.order_purchase_timestamp::DATE          AS purchase_date,
        date_trunc('month', o.order_purchase_timestamp)::DATE AS purchase_month,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        date_diff('day',
                  o.order_estimated_delivery_date::DATE,
                  o.order_delivered_customer_date::DATE)      AS days_vs_promise,
        date_diff('day',
                  o.order_purchase_timestamp::DATE,
                  o.order_delivered_customer_date::DATE)      AS delivery_days,
        a.order_revenue, a.items_price, a.freight,
        a.item_count, a.seller_count,
        r.review_score
    FROM stg_valid_orders o
    JOIN raw_customers   c ON o.customer_id = c.customer_id
    JOIN stg_order_agg   a ON o.order_id   = a.order_id
    LEFT JOIN stg_order_review r ON o.order_id = r.order_id
)
SELECT
    *,
    days_vs_promise > 0                AS is_late,
    GREATEST(days_vs_promise, 0)       AS days_late,
    ROW_NUMBER() OVER (PARTITION BY customer_unique_id
                       ORDER BY order_purchase_timestamp)  AS customer_order_seq,
    COUNT(*)     OVER (PARTITION BY customer_unique_id)    AS customer_total_orders,
    date_diff('day',
        LAG(order_purchase_timestamp) OVER (
            PARTITION BY customer_unique_id
            ORDER BY order_purchase_timestamp)::DATE,
        order_purchase_timestamp::DATE)                    AS days_since_prev_order
FROM base;

-- Grain: one row per line item on a valid order.
-- Used for seller and product analysis.
CREATE OR REPLACE TABLE fact_order_items AS
SELECT
    i.order_id,
    i.order_item_id,
    i.product_id,
    i.seller_id,
    i.price,
    i.freight_value,
    f.customer_unique_id,
    f.purchase_date,
    f.purchase_month,
    f.is_late,
    f.days_late,
    f.review_score,
    f.seller_count
FROM raw_order_items i
JOIN fact_orders f ON i.order_id = f.order_id;
