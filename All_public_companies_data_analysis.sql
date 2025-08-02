CREATE TABLE public.companies_with_new_features (
    company VARCHAR(255),
    sector VARCHAR(255),
    industry VARCHAR(255),
    website VARCHAR(255),
    city VARCHAR(255),
    country VARCHAR(255),
    CEO VARCHAR(255),
    ceo_gender VARCHAR(50),
    employees INT,
    employee_type VARCHAR(100),
    revenues NUMERIC,
    revenue_type VARCHAR(100),
    free_cash_flow NUMERIC,
    debt NUMERIC,
    profits NUMERIC,
    assets NUMERIC,
    market_cap NUMERIC,
    date DATE,
    profit_margin NUMERIC,
    cash_flow_to_debt NUMERIC,
    revenue_per_employee NUMERIC,
    fcf_per_employee NUMERIC
);


COPY companies_with_new_features
FROM 'C:\Users\priya\Downloads\companies_with_new_features.csv'
DELIMITER ',' CSV HEADER;


SELECT * FROM companies_with_new_features;


-- 1. Revenue Analysis Query:
SELECT
    EXTRACT(YEAR FROM DATE) AS fiscal_year,
    SUM(revenues) AS total_revenues,
    AVG(revenues) AS avg_revenue,
    COUNT(DISTINCT company) AS company_count
FROM companies_with_new_features
GROUP BY EXTRACT(YEAR FROM DATE)
ORDER BY fiscal_year DESC;


-- 2. Top Companies Analysis:
WITH RankedCompanies AS (
    SELECT
        company,
        sector,
        country,
        revenues AS total_revenue,
        profits AS profit,
        market_cap AS market_capitalization,
        (profits / NULLIF(revenues, 0)) * 100 AS profit_margin,
        ROW_NUMBER() OVER (ORDER BY revenues DESC) AS row_num
    FROM companies_with_new_features
    WHERE revenues IS NOT NULL
)
SELECT *
FROM RankedCompanies
WHERE row_num <= 10;


-- 3. Sector Performance Analysis:
SELECT
    sector,
    COUNT(DISTINCT company) AS company_count,
    AVG(revenues) AS avg_revenue,
    MAX(revenues) AS max_revenue,
    SUM(revenues) AS total_sector_revenue,
    AVG(CAST(profits AS FLOAT) / NULLIF(CAST(revenues AS FLOAT), 0) * 100) AS avg_profit_margin
FROM companies_with_new_features
WHERE sector IS NOT NULL
  AND revenues > 0
GROUP BY sector
ORDER BY AVG(revenues) DESC;


-- 4. Geographical Revenue Distribution:
SELECT
    country,
    COUNT(DISTINCT company) AS companies,
    SUM(revenues) AS total_revenue,
    MAX(revenues) AS highest_revenue,
    AVG(revenues) AS avg_revenue_per_company
FROM companies_with_new_features
WHERE country IS NOT NULL
  AND revenues IS NOT NULL
GROUP BY country
HAVING COUNT(DISTINCT company) >= 5
ORDER BY SUM(revenues) DESC;


-- 5. CEO Gender Analysis:
-- WITH GenderAnalysis AS (
--     SELECT
--         [CEO gender],
--         COUNT(DISTINCT company) AS company_count,
--         SUM(revenues) AS total_revenue,
--         SUM(profits) AS total_profit,
--         SUM(market_cap) AS total_market_cap
--     FROM companies_with_new_features
--     WHERE [CEO gender] IS NOT NULL
--     GROUP BY [CEO gender]
-- )

-- SELECT
--     [CEO gender],
--     company_count,
--     total_revenue / company_count AS avg_revenue,
--     total_profit / company_count AS avg_profit,
--     total_market_cap / company_count AS avg_market_cap
-- FROM GenderAnalysis
-- ORDER BY avg_revenue DESC;


-- 6. Debt to Revenue Analysis:
SELECT
    sector,
    COUNT(DISTINCT company) AS company_count,
    AVG(debt) AS avg_debt,
    AVG(revenues) AS avg_revenue,
    AVG(debt / NULLIF(revenues, 0)) AS avg_debt_to_revenue_ratio
FROM companies_with_new_features
WHERE debt IS NOT NULL
  AND revenues > 0
GROUP BY sector
ORDER BY AVG(debt / NULLIF(revenues, 0)) DESC;