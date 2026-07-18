/* =====================================================================
   03_analysis_queries.sql
   Ready-to-run analysis queries against the star schema. These are the
   same questions the Power BI report answers visually — run them here
   to sanity-check the report, or reuse them as the basis for new
   visuals. Tested against SQLite; ANSI-standard enough to run on
   PostgreSQL / SQL Server / MySQL with no changes.
   ===================================================================== */

-- 1. Headline KPIs: total sales, profit, shipping cost, margin, orders
SELECT
    ROUND(SUM(Sales), 2)                              AS TotalSales,
    ROUND(SUM(Profit), 2)                             AS TotalProfit,
    ROUND(SUM(ShippingCost), 2)                        AS TotalShippingCost,
    ROUND(SUM(Profit) * 1.0 / SUM(Sales), 4)            AS OverallProfitMargin,
    ROUND(SUM(ShippingCost) * 1.0 / SUM(Sales), 4)      AS OverallShippingCostRatio,
    COUNT(DISTINCT OrderID)                            AS TotalOrders,
    SUM(Quantity)                                      AS TotalUnitsShipped
FROM fact_sales;

-- 2. Shipping cost efficiency by Ship Mode (which mode eats the most margin?)
SELECT
    s.ShipMode,
    COUNT(*)                                            AS LineItems,
    ROUND(SUM(f.Sales), 2)                              AS TotalSales,
    ROUND(SUM(f.ShippingCost), 2)                       AS TotalShippingCost,
    ROUND(SUM(f.ShippingCost) * 1.0 / SUM(f.Sales), 4)  AS ShippingCostRatio,
    ROUND(AVG(f.ShippingCost), 2)                       AS AvgShippingCostPerLine
FROM fact_sales f
JOIN dim_shipping s ON f.ShippingKey = s.ShippingKey
GROUP BY s.ShipMode
ORDER BY ShippingCostRatio DESC;

-- 3. Order Priority vs Ship Mode fulfillment mix (are urgent orders actually
--    getting expedited shipping, or riding Standard Class anyway?)
SELECT
    s.OrderPriority,
    s.ShipMode,
    COUNT(*)                                            AS LineItems,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY s.OrderPriority), 1) AS PctOfPriorityTier
FROM fact_sales f
JOIN dim_shipping s ON f.ShippingKey = s.ShippingKey
GROUP BY s.OrderPriority, s.ShipMode
ORDER BY s.OrderPriority, LineItems DESC;

-- 4. Regional / market supply chain cost comparison
SELECT
    l.MarketGroup,
    l.Region,
    ROUND(SUM(f.Sales), 2)                              AS TotalSales,
    ROUND(SUM(f.Profit), 2)                             AS TotalProfit,
    ROUND(SUM(f.ShippingCost), 2)                       AS TotalShippingCost,
    ROUND(SUM(f.ShippingCost) * 1.0 / SUM(f.Sales), 4)  AS ShippingCostRatio,
    ROUND(SUM(f.Profit) * 1.0 / SUM(f.Sales), 4)        AS ProfitMargin
FROM fact_sales f
JOIN dim_location l ON f.LocationKey = l.LocationKey
GROUP BY l.MarketGroup, l.Region
ORDER BY TotalSales DESC;

-- 5. Category / Sub-Category profitability and shipping burden
SELECT
    p.Category,
    p.SubCategory,
    ROUND(SUM(f.Sales), 2)                              AS TotalSales,
    ROUND(SUM(f.Profit), 2)                             AS TotalProfit,
    ROUND(SUM(f.Profit) * 1.0 / SUM(f.Sales), 4)        AS ProfitMargin,
    ROUND(SUM(f.ShippingCost), 2)                       AS TotalShippingCost,
    SUM(f.Quantity)                                     AS UnitsSold
FROM fact_sales f
JOIN dim_product p ON f.ProductID = p.ProductID
GROUP BY p.Category, p.SubCategory
ORDER BY TotalProfit ASC;   -- loss-making sub-categories float to the top

-- 6. Discount depth vs profit erosion (does discounting kill margin?)
SELECT
    CASE
        WHEN f.Discount = 0 THEN '0% (no discount)'
        WHEN f.Discount <= 0.10 THEN '1-10%'
        WHEN f.Discount <= 0.20 THEN '11-20%'
        WHEN f.Discount <= 0.30 THEN '21-30%'
        ELSE '30%+'
    END                                                  AS DiscountBand,
    COUNT(*)                                             AS LineItems,
    ROUND(SUM(f.Sales), 2)                               AS TotalSales,
    ROUND(SUM(f.Profit), 2)                              AS TotalProfit,
    ROUND(SUM(f.Profit) * 1.0 / SUM(f.Sales), 4)         AS ProfitMargin
FROM fact_sales f
GROUP BY DiscountBand
ORDER BY MIN(f.Discount);

-- 7. Top 10 customers by sales, with their profit contribution
SELECT
    c.CustomerName,
    c.Segment,
    ROUND(SUM(f.Sales), 2)                               AS TotalSales,
    ROUND(SUM(f.Profit), 2)                              AS TotalProfit,
    COUNT(DISTINCT f.OrderID)                            AS OrderCount
FROM fact_sales f
JOIN dim_customer c ON f.CustomerID = c.CustomerID
GROUP BY c.CustomerName, c.Segment
ORDER BY TotalSales DESC
LIMIT 10;

-- 8. Weekly demand trend (units + sales by ISO week, for seasonality /
--    capacity planning)
SELECT
    d.Year,
    d.WeekNum,
    d.WeekStartDate,
    SUM(f.Quantity)                                      AS UnitsOrdered,
    ROUND(SUM(f.Sales), 2)                               AS TotalSales,
    COUNT(DISTINCT f.OrderID)                             AS OrderCount
FROM fact_sales f
JOIN dim_date d ON f.DateKey = d.DateKey
GROUP BY d.Year, d.WeekNum, d.WeekStartDate
ORDER BY d.Year, d.WeekNum;

-- 9. Products that are both high-shipping-cost AND low/negative margin
--    (candidates to re-price, re-source, or drop)
SELECT
    p.ProductName,
    p.Category,
    p.SubCategory,
    ROUND(SUM(f.Sales), 2)                               AS TotalSales,
    ROUND(SUM(f.Profit), 2)                              AS TotalProfit,
    ROUND(SUM(f.ShippingCost), 2)                        AS TotalShippingCost,
    ROUND(SUM(f.ShippingCost) * 1.0 / SUM(f.Sales), 4)   AS ShippingCostRatio
FROM fact_sales f
JOIN dim_product p ON f.ProductID = p.ProductID
GROUP BY p.ProductName, p.Category, p.SubCategory
HAVING SUM(f.Profit) < 0
ORDER BY ShippingCostRatio DESC
LIMIT 20;

-- 10. Country-level footprint: sales, profit, and shipping cost ratio
--     (for a Power BI map visual)
SELECT
    l.Country,
    l.Market,
    ROUND(SUM(f.Sales), 2)                               AS TotalSales,
    ROUND(SUM(f.Profit), 2)                              AS TotalProfit,
    ROUND(SUM(f.ShippingCost) * 1.0 / SUM(f.Sales), 4)   AS ShippingCostRatio,
    COUNT(DISTINCT f.OrderID)                            AS OrderCount
FROM fact_sales f
JOIN dim_location l ON f.LocationKey = l.LocationKey
GROUP BY l.Country, l.Market
ORDER BY TotalSales DESC;
