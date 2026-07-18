/* =====================================================================
   02_load_data.sql
   Loads the six star-schema CSVs (in /powerbi) into the tables created
   by 01_schema.sql. The CSVs are already the finished, cleaned,
   surrogate-keyed tables — this is a straight bulk load, not a
   transform step (the transform already happened in Python; see
   /README.md "How this project was built" for that logic if you want
   to reproduce it against a fresh CSV export).

   Load order matters: dimensions first, fact last (FK constraints).
   Pick the block that matches your engine and edit the file path.
   ===================================================================== */

-- ---------- PostgreSQL ----------
-- \copy dim_date      FROM 'powerbi/dim_date.csv'      DELIMITER ',' CSV HEADER;
-- \copy dim_customer  FROM 'powerbi/dim_customer.csv'  DELIMITER ',' CSV HEADER;
-- \copy dim_product   FROM 'powerbi/dim_product.csv'   DELIMITER ',' CSV HEADER;
-- \copy dim_location  FROM 'powerbi/dim_location.csv'  DELIMITER ',' CSV HEADER;
-- \copy dim_shipping  FROM 'powerbi/dim_shipping.csv'  DELIMITER ',' CSV HEADER;
-- \copy fact_sales    FROM 'powerbi/fact_sales.csv'    DELIMITER ',' CSV HEADER;

-- ---------- SQL Server ----------
-- BULK INSERT dim_date     FROM 'C:\project\powerbi\dim_date.csv'     WITH (FORMAT='CSV', FIRSTROW=2);
-- BULK INSERT dim_customer FROM 'C:\project\powerbi\dim_customer.csv' WITH (FORMAT='CSV', FIRSTROW=2);
-- BULK INSERT dim_product  FROM 'C:\project\powerbi\dim_product.csv'  WITH (FORMAT='CSV', FIRSTROW=2);
-- BULK INSERT dim_location FROM 'C:\project\powerbi\dim_location.csv' WITH (FORMAT='CSV', FIRSTROW=2);
-- BULK INSERT dim_shipping FROM 'C:\project\powerbi\dim_shipping.csv' WITH (FORMAT='CSV', FIRSTROW=2);
-- BULK INSERT fact_sales   FROM 'C:\project\powerbi\fact_sales.csv'   WITH (FORMAT='CSV', FIRSTROW=2);

-- ---------- MySQL ----------
-- LOAD DATA LOCAL INFILE 'powerbi/dim_date.csv'     INTO TABLE dim_date     FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- LOAD DATA LOCAL INFILE 'powerbi/dim_customer.csv' INTO TABLE dim_customer FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- LOAD DATA LOCAL INFILE 'powerbi/dim_product.csv'  INTO TABLE dim_product  FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- LOAD DATA LOCAL INFILE 'powerbi/dim_location.csv' INTO TABLE dim_location FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- LOAD DATA LOCAL INFILE 'powerbi/dim_shipping.csv' INTO TABLE dim_shipping FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
-- LOAD DATA LOCAL INFILE 'powerbi/fact_sales.csv'   INTO TABLE fact_sales   FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- ---------- SQLite ----------
-- A ready-to-use SQLite database (global_superstore.db) is already
-- included in /sqlite_db — these tables are pre-loaded, so you can
-- skip this file entirely and just open that .db. To rebuild it
-- yourself from the CSVs via the sqlite3 CLI:
-- .mode csv
-- .import --skip 1 powerbi/dim_date.csv dim_date
-- .import --skip 1 powerbi/dim_customer.csv dim_customer
-- .import --skip 1 powerbi/dim_product.csv dim_product
-- .import --skip 1 powerbi/dim_location.csv dim_location
-- .import --skip 1 powerbi/dim_shipping.csv dim_shipping
-- .import --skip 1 powerbi/fact_sales.csv fact_sales
