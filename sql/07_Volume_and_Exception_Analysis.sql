/*
=============================================================
ADVENTUREWORKS RESELLER SALES PROFITABILITY ANALYSIS

Script:
07_Volume_and_Exception_Analysis.sql

Business Purpose:
Evaluate the relationship between sales volume and
profitability and identify high-priority product exceptions
requiring management attention.

Business Questions:
1. Were the highest-volume Road and Touring Bike products
   profitable?
2. Did high unit sales compensate for unfavorable product
   economics?
3. Which individual products generated the largest losses?
4. Which products should receive the highest priority for
   profitability review?

Key SQL Skills:
- TOP
- SUM
- COUNT DISTINCT
- CASE
- LEFT JOIN
- GROUP BY
- HAVING
- ORDER BY
- Volume and profitability analysis
- Exception classification
- Management prioritization

Dataset:
AdventureWorksDW2022

Author:
Tina Vo
=============================================================
*/

-- =========================================================
-- SECTION 1: Top 10 High-Volume Road and Touring Products
-- =========================================================
-- Purpose:
-- Identify the highest-volume Road and Touring Bike products
-- and compare sales volume with gross profitability.

SELECT TOP 10
    ps.EnglishProductSubcategoryName
        AS ProductSubcategory,

    p.EnglishProductName
        AS ProductName,

    SUM(s.OrderQuantity)
        AS TotalUnitsSold,

    COUNT(DISTINCT s.SalesOrderNumber)
        AS TotalOrders,

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
    ps.EnglishProductSubcategoryName,
    p.EnglishProductName

ORDER BY
    TotalUnitsSold DESC;

    -- =========================================================
-- SECTION 2: Executive Product Profitability Exceptions
-- =========================================================
-- Purpose:
-- Identify the largest loss-making Road and Touring Bike
-- products and classify them by management review priority.
--
-- Note:
-- Exception thresholds are analytical thresholds created
-- for this portfolio project and are not official
-- AdventureWorks business rules.
-- =========================================================

WITH ProductProfitability AS
(
    SELECT
        ps.EnglishProductSubcategoryName
            AS ProductSubcategory,

        p.EnglishProductName
            AS ProductName,

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
        ps.EnglishProductSubcategoryName,
        p.EnglishProductName
)

SELECT TOP 10
    ProductSubcategory,
    ProductName,
    TotalUnitsSold,
    TotalRevenue,
    TotalCost,
    GrossProfit,
    GrossMarginPct,

    CASE
        WHEN GrossProfit <= -100000
            THEN 'Critical'

        WHEN GrossProfit <= -50000
            THEN 'High'

        ELSE 'Moderate'
    END AS ExceptionPriority

FROM ProductProfitability

WHERE
    GrossProfit < 0

ORDER BY
    GrossProfit ASC;