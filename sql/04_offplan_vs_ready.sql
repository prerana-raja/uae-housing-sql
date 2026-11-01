-- Q4. Do off-plan units price differently from ready units of the same type?
WITH ranked AS (
    SELECT property_type, completion_status, price_per_sqft,
           ROW_NUMBER() OVER (PARTITION BY property_type, completion_status ORDER BY price_per_sqft) AS rn,
           COUNT(*)     OVER (PARTITION BY property_type, completion_status)                         AS n
    FROM listings
    WHERE property_type IN ('Apartment', 'Villa', 'Townhouse')
),
medians AS (
    SELECT property_type, completion_status, MAX(n) AS listings,
           AVG(CASE WHEN rn IN ((n + 1) / 2, (n + 2) / 2) THEN price_per_sqft END) AS median_ppsf
    FROM ranked
    GROUP BY property_type, completion_status
)
SELECT property_type,
       MAX(CASE WHEN completion_status = 'Ready'    THEN listings END)           AS ready_listings,
       MAX(CASE WHEN completion_status = 'Off-Plan' THEN listings END)           AS off_plan_listings,
       ROUND(MAX(CASE WHEN completion_status = 'Ready'    THEN median_ppsf END), 0) AS ready_median_ppsf,
       ROUND(MAX(CASE WHEN completion_status = 'Off-Plan' THEN median_ppsf END), 0) AS off_plan_median_ppsf,
       ROUND(100.0 * (MAX(CASE WHEN completion_status = 'Off-Plan' THEN median_ppsf END)
                    / MAX(CASE WHEN completion_status = 'Ready'    THEN median_ppsf END) - 1), 1) AS off_plan_premium_pct
FROM medians
GROUP BY property_type
ORDER BY property_type;
