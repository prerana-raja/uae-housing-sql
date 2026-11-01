-- Q7. Is there a furnished premium? Ready apartments in communities with 15+ listings of each kind.
WITH ranked AS (
    SELECT location, furnishing, price_per_sqft,
           ROW_NUMBER() OVER (PARTITION BY location, furnishing ORDER BY price_per_sqft) AS rn,
           COUNT(*)     OVER (PARTITION BY location, furnishing)                         AS n
    FROM listings
    WHERE property_type = 'Apartment' AND completion_status = 'Ready'
),
medians AS (
    SELECT location, furnishing, MAX(n) AS listings,
           AVG(CASE WHEN rn IN ((n + 1) / 2, (n + 2) / 2) THEN price_per_sqft END) AS median_ppsf
    FROM ranked
    GROUP BY location, furnishing
)
SELECT location,
       MAX(CASE WHEN furnishing = 'Furnished'   THEN listings END)                  AS furnished_listings,
       MAX(CASE WHEN furnishing = 'Unfurnished' THEN listings END)                  AS unfurnished_listings,
       ROUND(MAX(CASE WHEN furnishing = 'Furnished'   THEN median_ppsf END), 0)     AS furnished_median_ppsf,
       ROUND(MAX(CASE WHEN furnishing = 'Unfurnished' THEN median_ppsf END), 0)     AS unfurnished_median_ppsf,
       ROUND(100.0 * (MAX(CASE WHEN furnishing = 'Furnished' THEN median_ppsf END)
                    / MAX(CASE WHEN furnishing = 'Unfurnished' THEN median_ppsf END) - 1), 1) AS furnished_premium_pct
FROM medians
GROUP BY location
HAVING MIN(listings) >= 15 AND COUNT(*) = 2
ORDER BY furnished_premium_pct DESC;
