# Global Superstore — Supply Chain & Sales Analytics

SQL + Excel analytics project on the Global Superstore dataset (51,290 order
lines, 147 countries, 2011–2014): a star-schema SQL database and a
formula-driven Excel dashboard with 8 charts, all built from the same
cleaned data.

## Dashboard results

<table>
<tr>
<td><img src="results/01_shipping_cost_ratio_by_shipmode.png" width="420"/></td>
<td><img src="results/02_priority_vs_shipmode.png" width="420"/></td>
</tr>
<tr>
<td><img src="results/03_sales_profit_by_region.png" width="420"/></td>
<td><img src="results/04_profit_by_subcategory.png" width="420"/></td>
</tr>
<tr>
<td><img src="results/05_profit_margin_by_discount_band.png" width="420"/></td>
<td><img src="results/06_weekly_sales_trend.png" width="420"/></td>
</tr>
<tr>
<td><img src="results/07_top10_customers.png" width="420"/></td>
<td><img src="results/08_top15_countries.png" width="420"/></td>
</tr>
</table>

These same 8 charts are embedded live in `excel/Global_Superstore_Dashboard.xlsx`
(GitHub can't render Excel's native charts inline, which is why the PNGs
above exist separately in `/results`).

## Repo structure

```
├── README.md
├── excel/
│   └── Global_Superstore_Dashboard.xlsx   ← the dashboard (open this)
├── results/                               ← the 8 charts as standalone PNGs
├── sql/
│   ├── 01_schema.sql                      ← star-schema DDL
│   ├── 02_load_data.sql                   ← load scripts per engine
│   └── 03_analysis_queries.sql            ← 10 supply-chain / sales queries
└── sqlite_db/
    └── global_superstore.db               ← pre-built, pre-loaded SQLite DB
```

## The Excel dashboard

`excel/Global_Superstore_Dashboard.xlsx` has 11 sheets:

- **Dashboard** — 8 KPI cards + 8 charts, all formulas
- **Data** — the full 51,290-row cleaned fact table
- **Summary_ShipMode, Summary_Priority_ShipMode, Summary_Region,
  Summary_Category, Summary_Discount, Summary_WeeklyTrend** — aggregation
  tables, computed with `SUMIFS`/`COUNTIFS`/`AVERAGEIFS` against the Data
  sheet (not pasted values — change a number in Data and everything downstream
  recalculates)
- **Top10_Customers, Top20_LossProducts, Top15_Countries** — curated
  rankings with live `SUMIF` formulas
- **Dim_OrderIDs** — hidden helper sheet (deduplicated Order IDs, used for a
  fast distinct-order-count KPI)

## SQL query results

Don't want to run the queries yourself? **[sql/results/RESULTS.md](sql/results/RESULTS.md)**
has the output table for all 10 queries, rendered right on GitHub. Each
query's full result set is also saved as its own CSV in `sql/results/`.

## The SQL side

Star schema (`fact_sales` grain = one order line) with `dim_customer`,
`dim_product`, `dim_location`, `dim_shipping`, `dim_date`. `sqlite_db/global_superstore.db`
is already built and loaded — open it with
[DB Browser for SQLite](https://sqlitebrowser.org/) or the `sqlite3` CLI and
run the queries in `sql/03_analysis_queries.sql` directly. For SQL
Server/PostgreSQL/MySQL, run `sql/01_schema.sql` then the matching block in
`sql/02_load_data.sql`.

## ⚠️ Data quality note

The source CSV's `Order Date` and `Ship Date` columns were corrupted on
export (every row read the literal string `00:00.0`), so there's no real
date or shipping-duration data in this dataset. `Year` and ISO `weeknum`
were fully populated in every row, so those were used to build a weekly
time dimension instead (`WeekStartDate` = Monday of that ISO week) — good
enough for trend charts and YoY/WoW comparisons, but not a substitute for
true order/ship dates. If you have an uncorrected source export, both the
SQL and Excel models can take real dates in with no other changes.

## Key findings

- **Shipping cost eats the most margin on expedited shipping**: Same Day
  (17.4%) and First Class (16.8%) shipping cost ratios run nearly double
  Standard Class (8.1%).
- **Tables are the only sub-category losing money overall** despite being a
  top seller — a discounting/freight cost problem, not a demand problem.
- **Heavy discounting kills margin fast**: 0% discount orders run a 25.3%
  profit margin; 30%+ discount orders are net loss-making.
- **North America and the US dominate both sales and order volume**, but
  APAC and EU carry noticeably higher shipping cost ratios.
