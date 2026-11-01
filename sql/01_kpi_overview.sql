-- Q1. The dashboard's 5 KPIs, reproduced in SQL.
-- SQLite has no MEDIAN(), so medians use ROW_NUMBER() and pick the middle row(s).
WITH ranked AS (
    SELECT price_aed, price_per_sqft, area_sqft,
           ROW_NUMBER() OVER (ORDER BY price_aed)      AS rn_price,
           ROW_NUMBER() OVER (ORDER BY price_per_sqft) AS rn_ppsf,
           ROW_NUMBER() OVER (ORDER BY area_sqft)      AS rn_size,
           COUNT(*) OVER ()                            AS n
    FROM listings
)
SELECT
    MAX(n)                                                         AS listings,
    ROUND(AVG(CASE WHEN rn_price IN ((n + 1) / 2, (n + 2) / 2) THEN price_aed END), 0)      AS median_price_aed,
    ROUND(AVG(CASE WHEN rn_ppsf  IN ((n + 1) / 2, (n + 2) / 2) THEN price_per_sqft END), 1) AS median_price_per_sqft,
    ROUND(AVG(CASE WHEN rn_size  IN ((n + 1) / 2, (n + 2) / 2) THEN area_sqft END), 0)      AS median_size_sqft,
    (SELECT ROUND(100.0 * SUM(completion_status = 'Off-Plan') / COUNT(*), 1) FROM listings) AS off_plan_share_pct,
    (SELECT ROUND(AVG(price_aed), 0) FROM listings)                AS mean_price_aed_for_comparison
FROM ranked;
