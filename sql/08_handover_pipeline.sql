-- Q8. Off-plan supply pipeline: how many off-plan units hand over each quarter, and at what price?
WITH ranked AS (
    SELECT handover_year, handover_quarter, price_per_sqft,
           ROW_NUMBER() OVER (PARTITION BY handover_year, handover_quarter ORDER BY price_per_sqft) AS rn,
           COUNT(*)     OVER (PARTITION BY handover_year, handover_quarter)                         AS n
    FROM listings
    WHERE completion_status = 'Off-Plan'
),
quarterly AS (
    SELECT handover_year, handover_quarter, MAX(n) AS off_plan_listings,
           ROUND(AVG(CASE WHEN rn IN ((n + 1) / 2, (n + 2) / 2) THEN price_per_sqft END), 0) AS median_ppsf
    FROM ranked
    GROUP BY handover_year, handover_quarter
)
SELECT handover_year || ' ' || handover_quarter                            AS handover,
       off_plan_listings,
       median_ppsf,
       SUM(off_plan_listings) OVER (ORDER BY handover_year, handover_quarter) AS cumulative_listings,
       ROUND(100.0 * SUM(off_plan_listings) OVER (ORDER BY handover_year, handover_quarter)
             / SUM(off_plan_listings) OVER (), 1)                          AS cumulative_share_pct
FROM quarterly
ORDER BY handover_year, handover_quarter;
