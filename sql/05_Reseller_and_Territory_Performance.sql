/*
=============================================================
ADVENTUREWORKS RESELLER SALES PROFITABILITY ANALYSIS

Script:
05_Reseller_and_Territory_Performance.sql

Business Purpose:
Analyze reseller account and geographic territory performance
to determine whether 2013 profitability losses were
concentrated among specific customers or regions.

Business Questions:
1. Which reseller accounts generated the largest losses?
2. Which reseller business types were most associated with
   negative profitability?
3. Which sales territories were profitable or unprofitable?
4. Were Road and Touring Bike losses concentrated in specific
   territories or broadly distributed?

Key SQL Skills:
- SUM
- COUNT DISTINCT
- CASE
- LEFT JOIN
- GROUP BY
- HAVING
- ORDER BY
- TOP
- Reseller performance analysis
- Geographic profitability analysis

Dataset:
AdventureWorksDW2022

Author:
Tina Vo
=============================================================
*/

-- =========================================================
-- SECTION 1: Top 10 Loss-Making Resellers in 2013
-- =========================================================
-- Purpose:
-- Identify reseller accounts that generated the largest
-- negative gross profit during 2013.

SELECT TOP 10
    r.ResellerName,
    r.BusinessType,

    SUM(s.SalesAmount) AS TotalRevenue,
    SUM(s.TotalProductCost) AS TotalCost,

    SUM(s.SalesAmount - s.TotalProductCost)
        AS GrossProfit,

    CASE
        WHEN SUM(s.SalesAmount) <> 0
        THEN SUM(s.SalesAmount - s.TotalProductCost)
             / SUM(s.SalesAmount)
        ELSE NULL
    END AS GrossMarginPct,

    SUM(s.OrderQuantity) AS TotalUnitsSold,

    COUNT(DISTINCT s.SalesOrderNumber)
        AS TotalOrders

FROM dbo.FactResellerSales AS s

LEFT JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey

LEFT JOIN dbo.DimReseller AS r
    ON s.ResellerKey = r.ResellerKey

WHERE
    d.CalendarYear = 2013

GROUP BY
    r.ResellerName,
    r.BusinessType

HAVING
    SUM(s.SalesAmount - s.TotalProductCost) < 0

ORDER BY
    GrossProfit ASC;

    -- =========================================================
-- SECTION 2: 2013 Profitability by Reseller Business Type
-- =========================================================
-- Purpose:
-- Compare revenue, cost, gross profit, and gross margin
-- across reseller business types to determine whether
-- profitability problems were concentrated within a
-- particular customer segment.

SELECT
    r.BusinessType,

    COUNT(DISTINCT r.ResellerKey) AS ActiveResellers,

    COUNT(DISTINCT s.SalesOrderNumber) AS TotalOrders,

    SUM(s.OrderQuantity) AS TotalUnitsSold,

    SUM(s.SalesAmount) AS TotalRevenue,

    SUM(s.TotalProductCost) AS TotalCost,

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

LEFT JOIN dbo.DimReseller AS r
    ON s.ResellerKey = r.ResellerKey

WHERE
    d.CalendarYear = 2013

GROUP BY
    r.BusinessType

ORDER BY
    GrossProfit ASC;

    -- =========================================================
-- SECTION 3: 2013 Profitability by Sales Territory
-- =========================================================
-- Purpose:
-- Compare profitability across geographic sales territories
-- to determine whether 2013 losses were concentrated within
-- specific regions or broadly distributed.

SELECT
    t.SalesTerritoryRegion,
    t.SalesTerritoryCountry,
    t.SalesTerritoryGroup,

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

LEFT JOIN dbo.DimSalesTerritory AS t
    ON s.SalesTerritoryKey = t.SalesTerritoryKey

WHERE
    d.CalendarYear = 2013

GROUP BY
    t.SalesTerritoryRegion,
    t.SalesTerritoryCountry,
    t.SalesTerritoryGroup

ORDER BY
    GrossProfit ASC;

    -- =========================================================
-- SECTION 4: 2013 Road and Touring Bike Profitability
--            by Sales Territory
-- =========================================================
-- Purpose:
-- Determine whether Road and Touring Bike losses were
-- concentrated within specific territories or broadly
-- distributed across geographic markets.

SELECT
    t.SalesTerritoryRegion,

    t.SalesTerritoryCountry,

    ps.EnglishProductSubcategoryName
        AS ProductSubcategory,

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

LEFT JOIN dbo.DimSalesTerritory AS t
    ON s.SalesTerritoryKey = t.SalesTerritoryKey

WHERE
    d.CalendarYear = 2013

    AND ps.EnglishProductSubcategoryName
        IN ('Road Bikes', 'Touring Bikes')

GROUP BY
    t.SalesTerritoryRegion,
    t.SalesTerritoryCountry,
    ps.EnglishProductSubcategoryName

ORDER BY
    t.SalesTerritoryRegion,
    GrossProfit ASC;