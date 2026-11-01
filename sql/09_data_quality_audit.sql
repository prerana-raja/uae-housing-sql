-- Q9. Data-governance check: how many listings carry a data-quality flag,
-- and does keeping them change the headline price-per-sq-ft KPI?
WITH base AS (
    SELECT dq_flag, price_per_sqft,
           ROW_NUMBER() OVER (PARTITION BY dq_flag ORDER BY price_per_sqft) AS rn,
           COUNT(*)     OVER (PARTITION BY dq_flag)                         AS n
    FROM listings
)
SELECT dq_flag,
       MAX(n)                                                       AS listings,
       ROUND(100.0 * MAX(n) / (SELECT COUNT(*) FROM listings), 1)   AS share_pct,
       ROUND(AVG(CASE WHEN rn IN ((n + 1) / 2, (n + 2) / 2) THEN price_per_sqft END), 0) AS median_ppsf
FROM base
GROUP BY dq_flag
ORDER BY listings DESC;
