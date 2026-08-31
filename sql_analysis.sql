-- =====================================================================
-- PROJECT: Credit Card Customer Experience & Complaint Driver Analysis
-- SOURCE:  CFPB Consumer Complaint Database (cleaned in Python)
-- FILE:    cc_complaints_clean.csv (21,283 rows)
-- PURPOSE: Run structured business queries on cleaned complaint data
--          to support CX insights (issue trends, state/company
--          breakdowns), complementing the Python NLP/sentiment analysis.
--
-- NOTE: Table was loaded directly from pandas (df.to_sql), so column
--       names match the original CSV headers exactly, including spaces.
--       Columns with spaces require backticks in every query below.
-- =====================================================================


-- -----------------------------------------------------------------
-- STEP 1: Select the database to use
-- -----------------------------------------------------------------
USE cc_complaints_db;


-- -----------------------------------------------------------------
-- STEP 2: Sanity check — confirm the data loaded correctly
-- Expected result: 21283
-- -----------------------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM complaints;


-- -----------------------------------------------------------------
-- STEP 3: Confirm table structure and exact column names
-- -----------------------------------------------------------------
DESCRIBE complaints;


-- =====================================================================
-- ANALYSIS QUERIES
-- =====================================================================


-- -----------------------------------------------------------------
-- QUERY 1: Average sentiment and complaint volume by issue category
-- Purpose: Identify which issue types generate the most negative
--          sentiment, and how many complaints fall into each —
--          replicates the Python groupby but as a SQL business query.
-- -----------------------------------------------------------------
SELECT
    Issue,
    ROUND(AVG(sentiment), 4) AS avg_sentiment,
    COUNT(*) AS complaint_count
FROM complaints
GROUP BY Issue
ORDER BY avg_sentiment ASC;


-- -----------------------------------------------------------------
-- QUERY 2: Top 10 states by complaint volume for the worst-sentiment
--          issue category (credit reporting investigation disputes)
-- Purpose: Check if this issue is concentrated in specific states,
--          which could point to a regional servicing/process gap.
-- -----------------------------------------------------------------
SELECT
    State,
    COUNT(*) AS complaint_count
FROM complaints
WHERE Issue = 'Problem with a credit reporting company''s investigation into an existing problem'
GROUP BY State
ORDER BY complaint_count DESC
LIMIT 10;


-- -----------------------------------------------------------------
-- QUERY 3: Average sentiment by company response type
-- Purpose: SQL version of the Python ANOVA check — see whether
--          resolution type relates to how negative the complaint was.
-- -----------------------------------------------------------------
SELECT
    `Company response to consumer` AS company_response,
    ROUND(AVG(sentiment), 4) AS avg_sentiment,
    COUNT(*) AS complaint_count
FROM complaints
GROUP BY `Company response to consumer`
ORDER BY avg_sentiment ASC;


-- -----------------------------------------------------------------
-- QUERY 4: Top 10 companies by complaint volume
-- Purpose: Identify which companies receive the most complaints
--          overall, for context on the dataset's composition.
-- -----------------------------------------------------------------
SELECT
    Company,
    COUNT(*) AS complaint_count,
    ROUND(AVG(sentiment), 4) AS avg_sentiment
FROM complaints
GROUP BY Company
ORDER BY complaint_count DESC
LIMIT 10;


-- -----------------------------------------------------------------
-- QUERY 4b: American Express-specific issue breakdown
-- Purpose: Since this project targets an Amex Data Analyst role,
--          check whether Amex's own complaint pattern matches or
--          differs from the overall market trend found in Query 1.
--          NOTE: Several categories here have very small sample
--          sizes (<20 complaints) and should not be over-interpreted.
-- -----------------------------------------------------------------
SELECT
    Issue,
    COUNT(*) AS complaint_count,
    ROUND(AVG(sentiment), 4) AS avg_sentiment
FROM complaints
WHERE Company = 'AMERICAN EXPRESS COMPANY'
GROUP BY Issue
ORDER BY avg_sentiment ASC;


-- -----------------------------------------------------------------
-- QUERY 5: Monthly complaint trend
-- Purpose: See if complaint volume or sentiment is rising, falling,
--          or stable across the dataset's date range (Jan-Aug 2023).
-- -----------------------------------------------------------------
SELECT
    DATE_FORMAT(`Date received`, '%Y-%m') AS complaint_month,
    COUNT(*) AS complaint_count,
    ROUND(AVG(sentiment), 4) AS avg_sentiment
FROM complaints
GROUP BY complaint_month
ORDER BY complaint_month;


-- -----------------------------------------------------------------
-- QUERY 6: Timely vs. untimely response — sentiment comparison
-- Purpose: Check if late company responses correlate with worse
--          customer sentiment (a direct servicing-quality signal).
--          NOTE: "No" (untimely) group is very small (n=145) —
--          result should not be treated as a reliable finding.
-- -----------------------------------------------------------------
SELECT
    `Timely response?` AS timely_response,
    ROUND(AVG(sentiment), 4) AS avg_sentiment,
    COUNT(*) AS complaint_count
FROM complaints
GROUP BY `Timely response?`;