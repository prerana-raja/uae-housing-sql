-- Q2. Which communities are most expensive per sq ft? (areas with 30+ listings)
WITH ranked AS (
    SELECT location, price_aed, price_per_sqft, completion_status,
           ROW_NUMBER() OVER (PARTITION BY location ORDER BY price_per_sqft) AS rn,
           COUNT(*)     OVER (PARTITION BY location)                         AS n
    FROM listings
),
area_stats AS (
    SELECT location,
           MAX(n)                                                                    AS listings,
           ROUND(AVG(CASE WHEN rn IN ((n + 1) / 2, (n + 2) / 2) THEN price_per_sqft END), 0) AS median_ppsf,
           ROUND(100.0 * SUM(completion_status = 'Off-Plan') / COUNT(*), 1)          AS off_plan_share_pct
    FROM ranked
    GROUP BY location
    HAVING MAX(n) >= 30
)
SELECT RANK() OVER (ORDER BY median_ppsf DESC) AS rank_by_ppsf,
       location, listings, median_ppsf, off_plan_share_pct
FROM area_stats
ORDER BY rank_by_ppsf
LIMIT 15;
