/*
=============================================================
ADVENTUREWORKS RESELLER SALES PROFITABILITY ANALYSIS

Script:
01_Data_Exploration_and_Model.sql

Business Purpose:
Explore the AdventureWorksDW2022 data warehouse and validate
the fact-to-dimension relationships required for reseller
sales and profitability analysis.

Business Questions:
1. What is the primary sales fact table?
2. Which dimensions describe product, reseller, geography,
   promotion, and time?
3. Can the required tables be joined successfully for
   downstream profitability analysis?

Key SQL Skills:
- SELECT
- TOP
- LEFT JOIN
- Table aliases
- Fact and dimension modeling
- Data validation

Dataset:
AdventureWorksDW2022

Author:
Tina Vo
=============================================================
*/

-- =========================================================
-- SECTION 1: Inspect the Reseller Sales Fact Table
-- =========================================================
-- Purpose:
-- Review the transactional sales table containing order,
-- quantity, pricing, revenue, cost, and dimension keys.

SELECT TOP 100
    SalesOrderNumber,
    SalesOrderLineNumber,
    OrderDateKey,
    ProductKey,
    ResellerKey,
    SalesTerritoryKey,
    PromotionKey,
    OrderQuantity,
    UnitPrice,
    UnitPriceDiscountPct,
    DiscountAmount,
    SalesAmount,
    ProductStandardCost,
    TotalProductCost
FROM dbo.FactResellerSales;

-- =========================================================
-- SECTION 2: Inspect the Date Dimension
-- =========================================================
-- Purpose:
-- Validate calendar fields used for yearly, quarterly,
-- and monthly trend analysis.

SELECT TOP 100
    DateKey,
    FullDateAlternateKey,
    EnglishDayNameOfWeek,
    EnglishMonthName,
    MonthNumberOfYear,
    CalendarQuarter,
    CalendarYear,
    FiscalQuarter,
    FiscalYear
FROM dbo.DimDate
ORDER BY FullDateAlternateKey;

-- =========================================================
-- SECTION 3: Inspect the Product Hierarchy
-- =========================================================
-- Purpose:
-- Validate how sellable products connect to product
-- subcategories and product categories.

SELECT TOP 100
    p.ProductKey,
    p.EnglishProductName AS ProductName,
    p.ProductLine,
    p.ListPrice,
    p.DealerPrice,
    ps.EnglishProductSubcategoryName AS ProductSubcategory,
    pc.EnglishProductCategoryName AS ProductCategory

FROM dbo.DimProduct AS p

LEFT JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey

LEFT JOIN dbo.DimProductCategory AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey

WHERE
    ps.ProductSubcategoryKey IS NOT NULL
    AND pc.ProductCategoryKey IS NOT NULL

ORDER BY
    pc.EnglishProductCategoryName,
    ps.EnglishProductSubcategoryName,
    p.EnglishProductName;

-- =========================================================
-- SECTION 4: Inspect the Reseller Dimension
-- =========================================================
-- Purpose:
-- Review reseller account information used for
-- customer-level profitability analysis.

SELECT TOP 100
    ResellerKey,
    ResellerName,
    BusinessType

FROM dbo.DimReseller

ORDER BY
    ResellerName;

    -- =========================================================
-- SECTION 5: Inspect the Sales Territory Dimension
-- =========================================================
-- Purpose:
-- Review geographic fields required for regional
-- profitability analysis.

SELECT
    SalesTerritoryKey,
    SalesTerritoryRegion,
    SalesTerritoryCountry,
    SalesTerritoryGroup

FROM dbo.DimSalesTerritory

ORDER BY
    SalesTerritoryGroup,
    SalesTerritoryCountry,
    SalesTerritoryRegion;

    -- =========================================================
-- SECTION 6: Inspect the Promotion Dimension
-- =========================================================
-- Purpose:
-- Review promotion attributes used later to evaluate whether
-- discounting was associated with profitability erosion.

SELECT
    PromotionKey,
    EnglishPromotionName AS PromotionName,
    EnglishPromotionType AS PromotionType,
    EnglishPromotionCategory AS PromotionCategory,
    DiscountPct,
    StartDate,
    EndDate,
    MinQty,
    MaxQty

FROM dbo.DimPromotion

ORDER BY
    PromotionKey;

    -- =========================================================
-- SECTION 7: Validate the Analytical Data Model
-- =========================================================
-- Purpose:
-- Confirm that the reseller sales fact table successfully
-- connects to the core dimensions required for the project.

SELECT TOP 100
    s.SalesOrderNumber,
    s.SalesOrderLineNumber,
    d.FullDateAlternateKey AS OrderDate,
    d.CalendarYear,
    d.EnglishMonthName,
    p.EnglishProductName AS ProductName,
    ps.EnglishProductSubcategoryName AS ProductSubcategory,
    pc.EnglishProductCategoryName AS ProductCategory,
    r.ResellerName,
    r.BusinessType,
    t.SalesTerritoryRegion AS TerritoryRegion,
    t.SalesTerritoryCountry AS TerritoryCountry,
    t.SalesTerritoryGroup AS TerritoryGroup,
    pr.EnglishPromotionName AS PromotionName,
    s.OrderQuantity,
    s.UnitPrice,
    s.ProductStandardCost,
    s.SalesAmount,
    s.TotalProductCost,
    s.SalesAmount - s.TotalProductCost AS GrossProfit

FROM dbo.FactResellerSales AS s

LEFT JOIN dbo.DimDate AS d
    ON s.OrderDateKey = d.DateKey

LEFT JOIN dbo.DimProduct AS p
    ON s.ProductKey = p.ProductKey

LEFT JOIN dbo.DimProductSubcategory AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey

LEFT JOIN dbo.DimProductCategory AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey

LEFT JOIN dbo.DimReseller AS r
    ON s.ResellerKey = r.ResellerKey

LEFT JOIN dbo.DimSalesTerritory AS t
    ON s.SalesTerritoryKey = t.SalesTerritoryKey

LEFT JOIN dbo.DimPromotion AS pr
    ON s.PromotionKey = pr.PromotionKey

ORDER BY
    d.FullDateAlternateKey,
    s.SalesOrderNumber,
    s.SalesOrderLineNumber;

-- =========================================================
-- SECTION 8: Basic Dataset Validation
-- =========================================================
-- Purpose:
-- Confirm the size and basic coverage of the reseller
-- sales dataset before beginning detailed analysis.

SELECT
    COUNT(*) AS TotalSalesLines,
    COUNT(DISTINCT SalesOrderNumber) AS TotalOrders,
    MIN(OrderDate) AS FirstOrderDate,
    MAX(OrderDate) AS LastOrderDate,
    SUM(OrderQuantity) AS TotalUnitsSold,
    SUM(SalesAmount) AS TotalRevenue

FROM dbo.FactResellerSales;