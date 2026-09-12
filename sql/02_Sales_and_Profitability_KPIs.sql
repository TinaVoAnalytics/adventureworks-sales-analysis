/*
=============================================================
ADVENTUREWORKS RESELLER SALES PROFITABILITY ANALYSIS

Script:
02_Sales_and_Profitability_KPIs.sql

Business Purpose:
Measure overall reseller sales performance and profitability
using key business KPIs and year-over-year analysis.

Business Questions:
1. How much reseller sales revenue was generated?
2. What were total product cost and gross profit?
3. What was the overall gross margin percentage?
4. How many units and distinct orders were generated?
5. How did revenue and profitability change by year?

Key SQL Skills:
- SUM
- COUNT
- COUNT DISTINCT
- CASE
- Aggregate calculations
- Gross profit and gross margin analysis
- GROUP BY
- ORDER BY

Dataset:
AdventureWorksDW2022

Author:
Tina Vo
=============================================================
*/

-- =========================================================
-- SECTION 1: Overall Sales and Profitability KPIs
-- =========================================================
-- Purpose:
-- Establish the overall business performance baseline using
-- revenue, cost, gross profit, gross margin, units, and orders.

SELECT
    SUM(SalesAmount) AS TotalRevenue,
    SUM(TotalProductCost) AS TotalCost,
    SUM(SalesAmount - TotalProductCost) AS GrossProfit,

    CASE
        WHEN SUM(SalesAmount) <> 0
        THEN SUM(SalesAmount - TotalProductCost)
             / SUM(SalesAmount)
        ELSE NULL
    END AS GrossMarginPct,

    SUM(OrderQuantity) AS TotalUnitsSold,
    COUNT(DISTINCT SalesOrderNumber) AS TotalOrders

FROM dbo.FactResellerSales;

-- =========================================================
-- SECTION 2: Yearly Sales and Profitability Performance
-- =========================================================
-- Purpose:
-- Compare revenue, cost, gross profit, gross margin,
-- units, and orders across calendar years.

SELECT
    d.CalendarYear,
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

GROUP BY
    d.CalendarYear

ORDER BY
    d.CalendarYear;

    -- =========================================================
-- SECTION 3: 2013 vs. 2012 Performance Change
-- =========================================================
-- Purpose:
-- Quantify the change in revenue, gross profit, units,
-- and orders between 2012 and 2013.

WITH YearlyPerformance AS
(
    SELECT
        d.CalendarYear,
        SUM(s.SalesAmount) AS TotalRevenue,
        SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit,
        SUM(s.OrderQuantity) AS TotalUnitsSold,
        COUNT(DISTINCT s.SalesOrderNumber) AS TotalOrders

    FROM dbo.FactResellerSales AS s

    LEFT JOIN dbo.DimDate AS d
        ON s.OrderDateKey = d.DateKey

    WHERE d.CalendarYear IN (2012, 2013)

    GROUP BY
        d.CalendarYear
)

SELECT
    CalendarYear,
    TotalRevenue,
    GrossProfit,
    TotalUnitsSold,
    TotalOrders,

    LAG(TotalRevenue) OVER (ORDER BY CalendarYear) AS PriorYearRevenue,

    CASE
        WHEN LAG(TotalRevenue) OVER (ORDER BY CalendarYear) <> 0
        THEN (TotalRevenue -
              LAG(TotalRevenue) OVER (ORDER BY CalendarYear))
             / LAG(TotalRevenue) OVER (ORDER BY CalendarYear)
        ELSE NULL
    END AS RevenueGrowthPct,

    LAG(GrossProfit) OVER (ORDER BY CalendarYear) AS PriorYearGrossProfit

FROM YearlyPerformance

ORDER BY
    CalendarYear;

-- =========================================================
-- SECTION 4: Annual Gross Profit Change
-- =========================================================
-- Purpose:
-- Quantify the year-over-year change in gross profit to
-- identify periods of significant profitability deterioration.

WITH YearlyProfit AS
(
    SELECT
        d.CalendarYear,
        SUM(s.SalesAmount - s.TotalProductCost) AS GrossProfit

    FROM dbo.FactResellerSales AS s

    LEFT JOIN dbo.DimDate AS d
        ON s.OrderDateKey = d.DateKey

    GROUP BY
        d.CalendarYear
)

SELECT
    CalendarYear,
    GrossProfit,

    LAG(GrossProfit) OVER (ORDER BY CalendarYear)
        AS PriorYearGrossProfit,

    GrossProfit -
    LAG(GrossProfit) OVER (ORDER BY CalendarYear)
        AS GrossProfitChange

FROM YearlyProfit

ORDER BY
    CalendarYear;

    -- =========================================================
-- SECTION 5: Gross Margin Performance by Year
-- =========================================================
-- Purpose:
-- Evaluate annual gross margin performance to identify
-- changes in profitability efficiency over time.

SELECT
    d.CalendarYear,
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

GROUP BY
    d.CalendarYear

ORDER BY
    GrossMarginPct DESC;