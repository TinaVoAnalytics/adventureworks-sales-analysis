# SQL Analysis

## AdventureWorks Sales Finance & Pricing Analytics

**Dataset:** AdventureWorksDW2022  
**Database:** SQL Server  
**Primary Fact Table:** `dbo.FactResellerSales`

## Overview

This SQL analysis examines AdventureWorks reseller-sales data to evaluate revenue, profitability, product performance, pricing behavior, reseller and territory performance, promotional trends, sales volume, and business exceptions.

The analysis follows a structured workflow from data exploration and dimensional-model validation through detailed financial analysis and executive-level business insights. SQL outputs were subsequently incorporated into the Excel financial and pricing analysis for further modeling, visualization, and decision support.

## SQL Analysis Workflow

### 1. Data Exploration & Model
[`01_Data_Exploration_and_Model.sql`](01_Data_Exploration_and_Model.sql)

Explores the AdventureWorksDW2022 data warehouse, validates the reseller-sales fact table, and examines the dimension relationships required for downstream analysis.

**Key skills:** `SELECT`, `TOP`, `LEFT JOIN`, table aliases, fact/dimension modeling, data validation

### 2. Sales & Profitability KPIs
[`02_Sales_and_Profitability_KPIs.sql`](02_Sales_and_Profitability_KPIs.sql)

Calculates core financial and sales KPIs, including revenue, cost, gross profit, gross margin, order activity, and related performance measures.

**Key skills:** `SUM`, `COUNT`, `COUNT(DISTINCT)`, calculated measures, aggregation, financial KPI analysis

### 3. Product & Category Profitability
[`03_Product_and_Category_Profitability.sql`](03_Product_and_Category_Profitability.sql)

Evaluates sales and profitability across products, subcategories, and categories to identify major revenue and profit contributors.

**Key skills:** multi-table joins, `GROUP BY`, aggregation, product hierarchy analysis, profitability analysis

### 4. Price vs. Cost Analysis
[`04_Price_vs_Cost_Analysis.sql`](04_Price_vs_Cost_Analysis.sql)

Compares selling prices with product standard costs and classifies transactions according to pricing and margin conditions.

**Key skills:** `CASE`, conditional logic, cost comparison, gross-profit analysis, margin-risk identification

### 5. Reseller & Territory Performance
[`05_Reseller_and_Territory_Performance.sql`](05_Reseller_and_Territory_Performance.sql)

Analyzes commercial performance across resellers and sales territories to identify high-performing customers and geographic markets.

**Key skills:** dimensional joins, customer analysis, territory analysis, ranking and aggregation

### 6. Promotion & Time Trend Analysis
[`06_Promotion_and_Time_Trend_Analysis.sql`](06_Promotion_and_Time_Trend_Analysis.sql)

Examines sales performance across time periods and promotional activity to identify changes in revenue and profitability.

**Key skills:** date-dimension joins, annual/monthly trend analysis, promotion analysis, time-based aggregation

### 7. Volume & Exception Analysis
[`07_Volume_and_Exception_Analysis.sql`](07_Volume_and_Exception_Analysis.sql)

Investigates sales volume and business exceptions to identify unusual transactions, performance risks, and areas requiring management attention.

**Key skills:** conditional analysis, exception identification, volume analysis, business-rule evaluation

### 8. Executive Summary
[`08_Executive_Summary.sql`](08_Executive_Summary.sql)

Consolidates key analytical measures and business findings into an executive-level SQL summary for decision support.

**Key skills:** KPI consolidation, aggregation, executive reporting, business-focused SQL analysis

## SQL Skills Demonstrated

- SQL Server / T-SQL
- Fact and dimension modeling
- Multi-table joins
- `SELECT`, `WHERE`, `GROUP BY`, and `ORDER BY`
- `LEFT JOIN`
- `CASE` expressions and conditional logic
- `SUM`, `COUNT`, `COUNT(DISTINCT)`, `MIN`, `MAX`, and other aggregations
- Revenue, cost, gross profit, and gross margin calculations
- Product and category profitability analysis
- Pricing and margin analysis
- Reseller and territory performance analysis
- Time-series and promotional analysis
- Data validation and exception analysis
- Translating SQL outputs into business insights

## Analytical Flow

**Data Exploration → KPI Analysis → Product Profitability → Pricing & Cost Analysis → Reseller & Territory Performance → Promotion & Time Trends → Volume & Exceptions → Executive Summary**

The SQL analysis provides the analytical foundation for the broader **Sales Finance & Pricing Analytics** portfolio project, which integrates SQL Server, Excel, Power BI, and AI-assisted analysis.
