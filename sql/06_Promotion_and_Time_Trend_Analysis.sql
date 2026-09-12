/*
=============================================================
ADVENTUREWORKS RESELLER SALES PROFITABILITY ANALYSIS

Script:
06_Promotion_and_Time_Trend_Analysis.sql

Business Purpose:
Analyze promotion activity and time-based profitability trends
to determine whether Road and Touring Bike losses were
associated with specific promotions or persisted across time.

Business Questions:
1. How did Road and Touring Bike profitability vary by
   promotion?
2. Were losses limited to discounted transactions?
3. Which promotions were associated with the largest losses?
4. Did Road and Touring Bike losses persist throughout 2013?

Key SQL Skills:
- SUM
- COUNT DISTINCT
- CASE
- LEFT JOIN
- GROUP BY
- ORDER BY
- Promotion analysis
- Monthly trend analysis
- Gross profit and gross margin analysis

Dataset:
AdventureWorksDW2022

Author:
Tina Vo
=============================================================
*/

-- =========================================================
-- SECTION 1: 2013 Road and Touring Bike Profitability
--            by Promotion
-- =========================================================
-- Purpose:
-- Compare Road and Touring Bike profitability across
-- promotions to determine whether losses were limited
-- to promotional or discounted transactions.

SELECT
    pr.EnglishPromotionName AS PromotionName,

    SUM(s.OrderQuantity) AS TotalUnitsSold,

    SUM(s.SalesAmount) AS TotalRevenue,

    SUM(s.DiscountAmount) AS TotalDiscountAmount,

    SUM(s.TotalProductCost) AS TotalCost,

    SUM(s.SalesAmount - s.TotalProductCost)
        AS GrossProfit,

    CASE
        WHEN SUM(s.SalesAmount) <> 0
        THEN SUM(s.SalesAmount - s.TotalProductCost)
             / SUM(s.SalesAmount)
        ELSE NULL
    END AS GrossMarginPct,

    COUNT(DISTINCT s.SalesOrderNumber)
        AS TotalOrders

FROM dbo.FactResellerSales AS s

LEFT JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey

LEFT JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey

LEFT JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey

LEFT JOIN dbo.DimPromotion AS pr
    ON s.PromotionKey = pr.PromotionKey

WHERE
    d.CalendarYear = 2013

    AND ps.EnglishProductSubcategoryName
        IN ('Road Bikes', 'Touring Bikes')

GROUP BY
    pr.EnglishPromotionName

ORDER BY
    GrossProfit ASC;

    -- =========================================================
-- SECTION 2: 2013 Monthly Road and Touring Bike
--            Profitability Trend
-- =========================================================
-- Purpose:
-- Analyze monthly revenue and profitability to determine
-- whether Road and Touring Bike losses were concentrated
-- in specific months or persisted throughout 2013.

SELECT
    d.MonthNumberOfYear,
    d.EnglishMonthName AS MonthName,

    COUNT(DISTINCT s.SalesOrderNumber)
        AS TotalOrders,

    SUM(s.OrderQuantity)
        AS TotalUnitsSold,

    SUM(s.SalesAmount)
        AS TotalRevenue,

    SUM(s.TotalProductCost)
        AS TotalCost,

    SUM(s.SalesAmount - s.TotalProductCost)
        AS GrossProfit,

    CASE
        WHEN SUM(s.SalesAmount) <> 0
        THEN SUM(s.SalesAmount - s.TotalProductCost)
             / SUM(s.SalesAmount)
        ELSE NULL
    END AS GrossMarginPct

FROM dbo.FactResellerSales AS s

LEFT JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey

LEFT JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey

LEFT JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey

WHERE
    d.CalendarYear = 2013

    AND ps.EnglishProductSubcategoryName
        IN ('Road Bikes', 'Touring Bikes')

GROUP BY
    d.MonthNumberOfYear,
    d.EnglishMonthName

ORDER BY
    d.MonthNumberOfYear;