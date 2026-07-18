/* =====================================================================
   GLOBAL SUPERSTORE — SUPPLY CHAIN & SALES ANALYTICS
   01_schema.sql
   Star-schema DDL. Written in ANSI-standard SQL; works as-is (or with
   trivial type tweaks) on SQL Server, PostgreSQL and MySQL 8+.

   Grain of the fact table = one order line item (one Row ID).
   ===================================================================== */

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_customer;
DROP TABLE IF EXISTS dim_product;
DROP TABLE IF EXISTS dim_location;
DROP TABLE IF EXISTS dim_shipping;
DROP TABLE IF EXISTS dim_date;

/* ---------------------------------------------------------------------
   DIM_DATE
   NOTE ON SOURCE DATA QUALITY:
   The raw CSV's "Order Date" and "Ship Date" columns arrived corrupted
   (every row read '00:00.0' — a broken timestamp export, not real
   dates). Rather than fabricate calendar dates, this project builds a
   trustworthy time dimension from the two fields that WERE reliably
   populated in every row: Year and ISO WeekNum. WeekStartDate is the
   Monday of that ISO week — useful as a continuous axis for charts,
   but treat it as an approximation, not the true order date.
--------------------------------------------------------------------- */
CREATE TABLE dim_date (
    DateKey        INT PRIMARY KEY,      -- Year*100 + WeekNum, e.g. 201105
    Year           INT NOT NULL,
    WeekNum        INT NOT NULL,
    WeekStartDate  DATE NOT NULL,
    Quarter        VARCHAR(2) NOT NULL,
    MonthNum       INT NOT NULL,
    MonthName      VARCHAR(15) NOT NULL
);

CREATE TABLE dim_customer (
    CustomerID     VARCHAR(20) PRIMARY KEY,
    CustomerName   VARCHAR(100) NOT NULL,
    Segment        VARCHAR(20) NOT NULL       -- Consumer / Corporate / Home Office
);

CREATE TABLE dim_product (
    ProductID      VARCHAR(20) PRIMARY KEY,
    ProductName    VARCHAR(255) NOT NULL,
    Category       VARCHAR(50) NOT NULL,
    SubCategory    VARCHAR(50) NOT NULL
);

CREATE TABLE dim_location (
    LocationKey    INT PRIMARY KEY,
    Country        VARCHAR(60) NOT NULL,
    City           VARCHAR(60) NOT NULL,
    State          VARCHAR(60),
    Region         VARCHAR(30) NOT NULL,
    Market         VARCHAR(20) NOT NULL,      -- US / EU / LATAM / Africa / APAC / EMEA / Canada
    MarketGroup    VARCHAR(20) NOT NULL       -- US+Canada rolled into "North America"
);

CREATE TABLE dim_shipping (
    ShippingKey    INT PRIMARY KEY,
    ShipMode       VARCHAR(20) NOT NULL,      -- Same Day / First Class / Second Class / Standard Class
    OrderPriority  VARCHAR(15) NOT NULL       -- Critical / High / Medium / Low
);

CREATE TABLE fact_sales (
    RowID              INT PRIMARY KEY,
    OrderID            VARCHAR(20) NOT NULL,
    CustomerID         VARCHAR(20) NOT NULL,
    ProductID          VARCHAR(20) NOT NULL,
    LocationKey        INT NOT NULL,
    DateKey            INT NOT NULL,
    ShippingKey        INT NOT NULL,
    Sales              DECIMAL(12,4) NOT NULL,
    Quantity           INT NOT NULL,
    Discount           DECIMAL(6,4) NOT NULL,
    Profit             DECIMAL(12,4) NOT NULL,
    ShippingCost       DECIMAL(12,4) NOT NULL,
    ProfitMargin       DECIMAL(8,4),           -- Profit / Sales
    ShippingCostRatio  DECIMAL(8,4),           -- ShippingCost / Sales
    CONSTRAINT fk_fact_customer FOREIGN KEY (CustomerID) REFERENCES dim_customer(CustomerID),
    CONSTRAINT fk_fact_product  FOREIGN KEY (ProductID)  REFERENCES dim_product(ProductID),
    CONSTRAINT fk_fact_location FOREIGN KEY (LocationKey) REFERENCES dim_location(LocationKey),
    CONSTRAINT fk_fact_date     FOREIGN KEY (DateKey)     REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fact_shipping FOREIGN KEY (ShippingKey) REFERENCES dim_shipping(ShippingKey)
);

CREATE INDEX idx_fact_customer ON fact_sales(CustomerID);
CREATE INDEX idx_fact_product  ON fact_sales(ProductID);
CREATE INDEX idx_fact_location ON fact_sales(LocationKey);
CREATE INDEX idx_fact_date     ON fact_sales(DateKey);
CREATE INDEX idx_fact_shipping ON fact_sales(ShippingKey);
