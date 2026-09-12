/*
=============================================================
ADVENTUREWORKS RESELLER SALES PROFITABILITY ANALYSIS

Script:
03_Product_and_Category_Profitability.sql

Business Purpose:
Analyze reseller sales profitability by product category and
subcategory to identify which product groups contributed most
to the 2013 profitability decline.

Business Questions:
1. Which product categories generated the most revenue?
2. Which categories were profitable or unprofitable in 2013?
3. Which Bike subcategories drove the largest losses?
4. Which Bike subcategories remained profitable?

Key SQL Skills:
- SUM
- COUNT DISTINCT
- CASE
- LEFT JOIN
- GROUP BY
- ORDER BY
- Product hierarchy analysis
- Gross profit and gross margin analysis

Dataset:
AdventureWorksDW2022

Author:
Tina Vo
=============================================================
*/

-- =========================================================
-- SECTION 1: 2013 Profitability by Product Category
-- =========================================================
-- Purpose:
-- Compare revenue, cost, gross profit, gross margin,
-- units, and orders across product categories in 2013.

SELECT
    pc.EnglishProductCategoryName AS ProductCategory,
    SUM(s.SalesAmount) AS TotalRevenue,
    SUM(s.TotalProductCost) AS TotalCost,
    SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit,

    CASE
        WHEN SUM(s.SalesAmount) <> 0
        THEN SUM(s.SalesAmount - s.TotalProductCost)
             / SUM(s.SalesAmount)
        ELSE NULL
    END AS GrossMarginPct,

    SUM(s.OrderQuantity) AS TotalUnitsSold,
    COUNT(DISTINCT s.SalesOrderNumber) AS TotalOrders

FROM dbo.FactResellerSales AS s

LEFT JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey

LEFT JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey

LEFT JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey

LEFT JOIN dbo.DimProductCategory AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey

WHERE
    d.CalendarYear = 2013

GROUP BY
    pc.EnglishProductCategoryName

ORDER BY
    GrossProfit ASC;

    -- =========================================================
-- SECTION 2: 2013 Bike Subcategory Profitability
-- =========================================================
-- Purpose:
-- Drill into the Bikes category to identify which Bike
-- subcategories contributed to the 2013 gross profit loss.

SELECT
    ps.EnglishProductSubcategoryName AS ProductSubcategory,
    SUM(s.SalesAmount) AS TotalRevenue,
    SUM(s.TotalProductCost) AS TotalCost,
    SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit,

    CASE
        WHEN SUM(s.SalesAmount) <> 0
        THEN SUM(s.SalesAmount - s.TotalProductCost)
             / SUM(s.SalesAmount)
        ELSE NULL
    END AS GrossMarginPct,

    SUM(s.OrderQuantity) AS TotalUnitsSold,
    COUNT(DISTINCT s.SalesOrderNumber) AS TotalOrders

FROM dbo.FactResellerSales AS s

LEFT JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey

LEFT JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey

LEFT JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey

LEFT JOIN dbo.DimProductCategory AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey

WHERE
    d.CalendarYear = 2013
    AND pc.EnglishProductCategoryName = 'Bikes'

GROUP BY
    ps.EnglishProductSubcategoryName

ORDER BY
    GrossProfit ASC;

    -- =========================================================
-- SECTION 3: 2013 Road and Touring Product Profitability
-- =========================================================
-- Purpose:
-- Identify the individual Road and Touring Bike products
-- contributing the largest gross profit losses in 2013.

SELECT
    ps.EnglishProductSubcategoryName AS ProductSubcategory,
    p.EnglishProductName AS ProductName,
    SUM(s.SalesAmount) AS TotalRevenue,
    SUM(s.TotalProductCost) AS TotalCost,
    SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit,

    CASE
        WHEN SUM(s.SalesAmount) <> 0
        THEN SUM(s.SalesAmount - s.TotalProductCost)
             / SUM(s.SalesAmount)
        ELSE NULL
    END AS GrossMarginPct,

    SUM(s.OrderQuantity) AS TotalUnitsSold,
    COUNT(DISTINCT s.SalesOrderNumber) AS TotalOrders

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
    GrossProfit ASC;

    -- =========================================================
-- SECTION 4: Top 10 Loss-Making Road and Touring Products
-- =========================================================
-- Purpose:
-- Rank the Road and Touring Bike products generating the
-- largest gross profit losses in 2013 for management review.

SELECT TOP 10
    ps.EnglishProductSubcategoryName AS ProductSubcategory,
    p.EnglishProductName AS ProductName,
    SUM(s.SalesAmount) AS TotalRevenue,
    SUM(s.TotalProductCost) AS TotalCost,
    SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit,

    CASE
        WHEN SUM(s.SalesAmount) <> 0
        THEN SUM(s.SalesAmount - s.TotalProductCost)
             / SUM(s.SalesAmount)
        ELSE NULL
    END AS GrossMarginPct,

    SUM(s.OrderQuantity) AS TotalUnitsSold,
    COUNT(DISTINCT s.SalesOrderNumber) AS TotalOrders

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

HAVING
    SUM(s.SalesAmount - s.TotalProductCost) < 0

ORDER BY
    GrossProfit ASC;