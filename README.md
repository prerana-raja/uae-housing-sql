# Dubai Property Market Analysis in SQL

SQL analysis of 3,435 cleaned Dubai property listings. It reproduces the five KPIs from my [Looker Studio dashboard](https://github.com/prerana-raja/uae-housing-dashboard) in SQL, then goes further: area rankings, pricing by property type and bedrooms, off-plan vs ready pricing, outlier detection, a furnishing premium check, the off-plan handover pipeline, and a data-quality audit.

**Data:** a public Kaggle UAE housing listings dataset (asking prices from a listings snapshot, not completed transactions). The cleaning (5,380 raw rows to 3,435 validated records, with a data-quality log) was done in the dashboard project; this repo starts from that cleaned file in `data/`. Check the original dataset's licence on Kaggle before redistributing it.

## Business questions

| # | Question | Query | SQL techniques |
|---|----------|-------|----------------|
| 1 | What are the headline KPIs (listings, median price, median price per sq ft, median size, off-plan share)? | `01_kpi_overview.sql` | Median via `ROW_NUMBER()` (SQLite has no `MEDIAN`), conditional aggregation |
| 2 | Which communities are most expensive per sq ft? | `02_area_ranking.sql` | CTEs, partitioned medians, `RANK() OVER`, `HAVING` |
| 3 | How do price and price per sq ft change with property type and bedrooms? | `03_type_and_bedroom_pricing.sql` | Multi-column `PARTITION BY`, minimum group size |
| 4 | Do off-plan units price differently from ready units? | `04_offplan_vs_ready.sql` | Pivot with conditional `MAX(CASE ...)`, premium % |
| 5 | How is the market split by price band? | `05_price_band_mix.sql` | `SUM() OVER` share and cumulative share |
| 6 | Which listings are price outliers? | `06_outlier_detection.sql` | IQR rule from nearest-rank quartiles, joins |
| 7 | Is there a furnished premium? | `07_furnishing_premium.sql` | Paired medians per community, filtered with `HAVING` |
| 8 | When does off-plan supply hand over, and at what price? | `08_handover_pipeline.sql` | Running totals with window functions |
| 9 | Do flagged records distort the KPIs? | `09_data_quality_audit.sql` | Governance check, grouped medians |

## How to run

Requires Python 3.8+ (standard library only) and SQLite 3.25+ for window functions.

```bash
python load_data.py       # builds uae_housing.db from data/uae_housing_clean.csv
python run_analysis.py    # runs all queries, prints a preview, saves results/*.csv
```

You can also open `uae_housing.db` in DB Browser for SQLite or the `sqlite3` CLI and run the files in `sql/` directly.

## Key findings

- **KPIs:** 3,435 listings; median price AED 1.82M; median AED 1,670 per sq ft; median size 1,071 sq ft; 43.7% off-plan. The mean price (AED 3.73M) is about twice the median, which is why the dashboard uses medians.
- **Most expensive areas** (30+ listings): Dubai Harbour (AED 4,311 per sq ft), Palm Jumeirah (3,669) and Downtown Dubai (3,224) lead, well above the city median.
- **Size and price:** apartment price per sq ft rises with bedroom count, from about AED 1,626 for 1-bedrooms to 2,616 for 4-bedrooms.
- **Off-plan vs ready:** off-plan apartments list 11.6% above ready apartments per sq ft, while off-plan villas (-10.8%) and townhouses (-14.7%) list below their ready equivalents.
- **Price bands:** 55% of listings are under AED 2M; only 6.3% are above AED 10M.
- **Outliers:** 5.3% of apartments sit above the IQR fence of about AED 3,960 per sq ft, which is why averages mislead.
- **Furnishing:** furnished apartments list at a premium of roughly 8% to 28% in six communities (largest in Dubai Production City, Downtown and Sports City) but at a discount in JVC, Arjan and Business Bay, so there is no universal furnished premium.
- **Pipeline:** about half of off-plan listings (51.8%) hand over by the end of 2026.
- **Data quality:** 21.8% of records carry the `ready_but_future_handover` flag. Their median price per sq ft (1,672) is almost identical to unflagged records (1,668), so keeping them does not distort the KPI.

**Limitations:** prices are asking prices from one snapshot, groups are small in places (minimum group sizes are set in each query), and comparisons such as furnished vs unfurnished do not control for size, building age or view, so these are associations, not causal effects.

## Possible extensions

- Regress price per sq ft on location, type, bedrooms and furnishing in Python.
- Add a mortgage-affordability layer using price bands.
- Refresh with a newer listings snapshot and compare medians over time.
