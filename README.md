# Global Superstore — Supply Chain & Sales Analytics

An end-to-end data analytics project transforming a raw 51,290-row global retail dataset (147 countries, 2011–2014) into a robust **star-schema SQL database** and a fully dynamic, formula-driven **Excel dashboard**. 

**Core Skills Demonstrated:** Data Modeling (Star Schema), SQL (DDL, Aggregation, CTEs), Advanced Excel (`SUMIFS`, `COUNTIFS`, Dynamic Dashboards), Data Cleaning, and Business Intelligence.

---

## 📊 Key Business Insights
*Instead of just building a dashboard, I analyzed the data to answer business questions. Here is what I found:*

- **Discounting destroys margins at a specific threshold:** Orders with a 0% discount maintain a healthy 25.3% profit margin. However, any discount band exceeding 30% reliably results in net-loss orders.
- **"Tables" are a structural loss-leader:** Despite being a top-selling product globally, tables are the *only* sub-category losing money overall—pointing to a heavy freight and discounting problem rather than a lack of demand.
- **Premium shipping aggressively eats margin:** Same Day (17.4%) and First Class (16.8%) shipping cost ratios run nearly double that of Standard Class (8.1%).
- **Geographic cost disparities:** While North America and the US dominate total sales and order volume, the APAC and EU regions carry noticeably higher shipping cost ratios.

---

## 📈 Dashboard Results

*The charts below are generated dynamically in Excel. The standalone PNGs are stored in `/results` for GitHub preview purposes.*

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

---

## 🛠️ Technical Implementation

### 1. The Excel Dashboard (`excel/Global_Superstore_Dashboard.xlsx`)
Designed for strict data integrity. There are no hardcoded "pasted values"—if the underlying 51k-row data changes, the entire dashboard recalculates instantly.
- **Dashboard Sheet:** 8 KPI cards and 8 charts driven entirely by formulas.
- **Data Engine:** 6 aggregation tables computed dynamically using `SUMIFS`, `COUNTIFS`, and `AVERAGEIFS` against the cleaned fact table.
- **Live Rankings:** Curated Top 10/15 lists (Customers, Loss-Making Products, Countries) built with live `SUMIF` calculations.

### 2. The SQL Database (`sqlite_db/global_superstore.db`)
Built a proper dimensional data model from flat CSV files.
- **Architecture:** Star schema featuring one `fact_sales` table (grain = one order line) and five dimension tables (`dim_customer`, `dim_product`, `dim_location`, `dim_shipping`, `dim_date`).
- **Querying:** Engineered 10 complex supply-chain and sales queries (view the raw output tables in **[sql/results/RESULTS.md](sql/results/RESULTS.md)**).
- **Portability:** Included DDL and load scripts (`sql/01_schema.sql` and `sql/02_load_data.sql`) compatible with SQL Server, PostgreSQL, and MySQL.

---

## 💡 Problem Solving: Data Engineering Challenge
**The Issue:** The source dataset contained corrupted `Order Date` and `Ship Date` columns (exported as literal string `00:00.0`), breaking traditional time-series analysis. 
**The Solution:** Rather than discarding the temporal data, I utilized the intact `Year` and ISO `weeknum` columns to reverse-engineer a functional weekly time dimension (`WeekStartDate` = Monday of the ISO week). This salvaged the ability to perform accurate WoW/YoY trend analysis and build the Weekly Sales Trend metrics.

---

## 📂 Repository Navigation

```text
├── README.md
├── excel/
│   └── Global_Superstore_Dashboard.xlsx   ← The interactive dashboard
├── results/                               ← Dashboard charts rendered as PNGs
├── sql/
│   ├── 01_schema.sql                      ← Star-schema DDL
│   ├── 02_load_data.sql                   ← Load scripts per SQL engine
│   ├── 03_analysis_queries.sql            ← 10 supply-chain / sales queries
│   └── results/                           ← Output CSVs and Markdown results
└── sqlite_db/
    └── global_superstore.db               ← Pre-built, query-ready SQLite DB
