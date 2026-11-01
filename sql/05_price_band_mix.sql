-- Q5. Market structure by price band: share of listings, cumulative share, off-plan mix.
SELECT price_band,
       COUNT(*)                                                             AS listings,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)                   AS share_pct,
       ROUND(100.0 * SUM(COUNT(*)) OVER (ORDER BY MIN(price_aed)) / SUM(COUNT(*)) OVER (), 1) AS cumulative_share_pct,
       ROUND(100.0 * SUM(completion_status = 'Off-Plan') / COUNT(*), 1)     AS off_plan_share_pct,
       ROUND(100.0 * SUM(furnishing = 'Furnished') / COUNT(*), 1)           AS furnished_share_pct
FROM listings
GROUP BY price_band
ORDER BY MIN(price_aed);
