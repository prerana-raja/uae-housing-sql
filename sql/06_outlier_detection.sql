-- Q6. Outlier detection with the IQR rule on price per sq ft, by property type.
-- Quartiles use nearest-rank on ROW_NUMBER(); fence = Q3 + 1.5 * IQR.
WITH ranked AS (
    SELECT property_type, price_per_sqft,
           ROW_NUMBER() OVER (PARTITION BY property_type ORDER BY price_per_sqft) AS rn,
           COUNT(*)     OVER (PARTITION BY property_type)                         AS n
    FROM listings
),
quartiles AS (
    SELECT property_type, MAX(n) AS n,
           MAX(CASE WHEN rn = (n + 3) / 4       THEN price_per_sqft END) AS q1,
           MAX(CASE WHEN rn = (3 * n + 3) / 4   THEN price_per_sqft END) AS q3
    FROM ranked
    GROUP BY property_type
)
SELECT q.property_type,
       q.n                                                        AS listings,
       q.q1, q.q3,
       ROUND(q.q3 + 1.5 * (q.q3 - q.q1), 0)                       AS upper_fence,
       SUM(l.price_per_sqft > q.q3 + 1.5 * (q.q3 - q.q1))         AS outliers_above,
       ROUND(100.0 * SUM(l.price_per_sqft > q.q3 + 1.5 * (q.q3 - q.q1)) / q.n, 1) AS outlier_share_pct,
       ROUND(MAX(l.price_per_sqft), 0)                            AS max_ppsf
FROM quartiles q
JOIN listings l ON l.property_type = q.property_type
WHERE q.n >= 15
GROUP BY q.property_type
ORDER BY listings DESC;
