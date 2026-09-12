/*
=============================================================
ADVENTUREWORKS RESELLER SALES PROFITABILITY ANALYSIS

Script:
04_Price_vs_Cost_Analysis.sql

Business Purpose:
Evaluate the relationship between selling price and product
standard cost to determine whether below-cost sales were
associated with reseller profitability deterioration.

Business Questions:
1. How frequently were products sold below standard cost?
2. Which product categories had the highest below-cost activity?
3. Were Road and Touring Bikes frequently sold below cost?
4. How did below-cost selling change over time?
5. How did price-to-cost relationships differ across Bike
   subcategories?

Key SQL Skills:
- CASE
- SUM
- COUNT
- Conditional aggregation
- LEFT JOIN
- GROUP BY
- ORDER BY
- Price-to-cost classification
- Profitability analysis

Dataset:
AdventureWorksDW2022

Author:
Tina Vo
=============================================================
*/

-- =========================================================
-- SECTION 1: 2013 Price vs. Cost Classification
-- =========================================================
-- Purpose:
-- Classify 2013 reseller sales lines based on whether the
-- selling unit price was below, equal to, or above the
-- product standard cost.

SELECT
    CASE
        WHEN s.UnitPrice < s.ProductStandardCost
            THEN 'Below Cost'
        WHEN s.UnitPrice = s.ProductStandardCost
            THEN 'At Cost'
        ELSE 'Above Cost'
    END AS PriceCostStatus,

    COUNT(*) AS SalesLineCount,
    SUM(s.OrderQuantity) AS TotalUnitsSold,
    SUM(s.SalesAmount) AS TotalRevenue,
    SUM(s.TotalProductCost) AS TotalCost,
    SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit,

    CASE
        WHEN SUM(s.SalesAmount) <> 0
        THEN SUM(s.SalesAmount - s.TotalProductCost)
             / SUM(s.SalesAmount)
        ELSE NULL
    END AS GrossMarginPct

FROM dbo.FactResellerSales AS s

LEFT JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey

WHERE
    d.CalendarYear = 2013

GROUP BY
    CASE
        WHEN s.UnitPrice < s.ProductStandardCost
            THEN 'Below Cost'
        WHEN s.UnitPrice = s.ProductStandardCost
            THEN 'At Cost'
        ELSE 'Above Cost'
    END

ORDER BY
    GrossProfit ASC;

-- =========================================================
-- SECTION 2: 2013 Below-Cost Sales by Product Category
-- =========================================================
-- Purpose:
-- Identify which product categories had the greatest
-- concentration of reseller sales lines priced below
-- product standard cost in 2013.

SELECT
    pc.EnglishProductCategoryName AS ProductCategory,

    COUNT(*) AS BelowCostSalesLines,

    SUM(s.OrderQuantity) AS BelowCostUnitsSold,

    SUM(s.SalesAmount) AS TotalRevenue,

    SUM(s.TotalProductCost) AS TotalCost,

    SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit,

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

LEFT JOIN dbo.DimProductCategory AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey

WHERE
    d.CalendarYear = 2013
    AND s.UnitPrice < s.ProductStandardCost

GROUP BY
    pc.EnglishProductCategoryName

ORDER BY
    BelowCostSalesLines DESC;

    -- =========================================================
-- SECTION 3: 2013 Below-Cost Sales-Line Percentage by Category
-- =========================================================
-- Purpose:
-- Measure the percentage of each product category's sales
-- lines where UnitPrice was below ProductStandardCost.

SELECT
    pc.EnglishProductCategoryName AS ProductCategory,

    COUNT(*) AS TotalSalesLines,

    SUM(
        CASE
            WHEN s.UnitPrice < s.ProductStandardCost
            THEN 1
            ELSE 0
        END
    ) AS BelowCostSalesLines,

    CASE
        WHEN COUNT(*) <> 0
        THEN 1.0 * SUM(
            CASE
                WHEN s.UnitPrice < s.ProductStandardCost
                THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        ELSE NULL
    END AS BelowCostSalesLinePct,

    SUM(s.OrderQuantity) AS TotalUnitsSold,

    SUM(
        CASE
            WHEN s.UnitPrice < s.ProductStandardCost
            THEN s.OrderQuantity
            ELSE 0
        END
    ) AS BelowCostUnitsSold

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
    BelowCostSalesLinePct DESC;

    -- =========================================================
-- SECTION 4: Bike Below-Cost Sales Trend by Year
-- =========================================================
-- Purpose:
-- Evaluate how the percentage of Bike sales lines priced
-- below product standard cost changed over time.

SELECT
    d.CalendarYear,

    COUNT(*) AS TotalBikeSalesLines,

    SUM(
        CASE
            WHEN s.UnitPrice < s.ProductStandardCost
            THEN 1
            ELSE 0
        END
    ) AS BelowCostSalesLines,

    CASE
        WHEN COUNT(*) <> 0
        THEN 1.0 * SUM(
            CASE
                WHEN s.UnitPrice < s.ProductStandardCost
                THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        ELSE NULL
    END AS BelowCostSalesLinePct,

    SUM(s.OrderQuantity) AS TotalBikeUnits,

    SUM(
        CASE
            WHEN s.UnitPrice < s.ProductStandardCost
            THEN s.OrderQuantity
            ELSE 0
        END
    ) AS BelowCostUnits

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
    pc.EnglishProductCategoryName = 'Bikes'

GROUP BY
    d.CalendarYear

ORDER BY
    d.CalendarYear;

    -- =========================================================
-- SECTION 5: Bike Subcategory Below-Cost Trend by Year
-- =========================================================
-- Purpose:
-- Compare below-cost sales-line patterns across Road,
-- Touring, and Mountain Bike subcategories over time.

SELECT
    d.CalendarYear,
    ps.EnglishProductSubcategoryName AS ProductSubcategory,

    COUNT(*) AS TotalSalesLines,

    SUM(
        CASE
            WHEN s.UnitPrice < s.ProductStandardCost
            THEN 1
            ELSE 0
        END
    ) AS BelowCostSalesLines,

    CASE
        WHEN COUNT(*) <> 0
        THEN 1.0 * SUM(
            CASE
                WHEN s.UnitPrice < s.ProductStandardCost
                THEN 1
                ELSE 0
            END
        ) / COUNT(*)
        ELSE NULL
    END AS BelowCostSalesLinePct,

    SUM(s.OrderQuantity) AS TotalUnitsSold,

    SUM(
        CASE
            WHEN s.UnitPrice < s.ProductStandardCost
            THEN s.OrderQuantity
            ELSE 0
        END
    ) AS BelowCostUnitsSold

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
    pc.EnglishProductCategoryName = 'Bikes'

GROUP BY
    d.CalendarYear,
    ps.EnglishProductSubcategoryName

ORDER BY
    d.CalendarYear,
    ps.EnglishProductSubcategoryName;

-- =========================================================
-- SECTION 6: 2013 Bike Price-to-Cost Gap
-- =========================================================
-- Purpose:
-- Compare average unit selling price with average product
-- standard cost across Bike subcategories and quantify
-- the average price-to-cost gap.

SELECT
    ps.EnglishProductSubcategoryName AS ProductSubcategory,

    AVG(s.UnitPrice) AS AvgUnitPrice,
    AVG(s.ProductStandardCost) AS AvgStandardCost,

    AVG(s.UnitPrice - s.ProductStandardCost)
        AS AvgPriceCostGap,

    SUM(s.SalesAmount) AS TotalRevenue,
    SUM(s.TotalProductCost) AS TotalCost,
    SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit,

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

LEFT JOIN dbo.DimProductCategory AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey

WHERE
    d.CalendarYear = 2013
    AND pc.EnglishProductCategoryName = 'Bikes'

GROUP BY
    ps.EnglishProductSubcategoryName

ORDER BY
    AvgPriceCostGap ASC;