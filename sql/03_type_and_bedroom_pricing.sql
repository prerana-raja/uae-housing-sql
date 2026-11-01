-- Q3. How do median price and price per sq ft change with property type and bedrooms?
-- Groups with fewer than 15 listings are dropped so medians are meaningful.
WITH ranked AS (
    SELECT property_type, bedroom_label, bedrooms, price_aed, price_per_sqft,
           ROW_NUMBER() OVER (PARTITION BY property_type, bedroom_label ORDER BY price_per_sqft) AS rn_ppsf,
           ROW_NUMBER() OVER (PARTITION BY property_type, bedroom_label ORDER BY price_aed)      AS rn_price,
           COUNT(*)     OVER (PARTITION BY property_type, bedroom_label)                         AS n
    FROM listings
    WHERE property_type IN ('Apartment', 'Villa', 'Townhouse')
)
SELECT property_type, bedroom_label,
       MAX(n) AS listings,
       ROUND(AVG(CASE WHEN rn_price IN ((n + 1) / 2, (n + 2) / 2) THEN price_aed END), 0)      AS median_price_aed,
       ROUND(AVG(CASE WHEN rn_ppsf  IN ((n + 1) / 2, (n + 2) / 2) THEN price_per_sqft END), 0) AS median_ppsf
FROM ranked
GROUP BY property_type, bedroom_label, bedrooms
HAVING MAX(n) >= 15
ORDER BY property_type, bedrooms;
