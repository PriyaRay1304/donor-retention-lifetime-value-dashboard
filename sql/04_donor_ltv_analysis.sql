/* ---------------------------------------------------------
   Donor Lifetime Value (LTV) Analysis
   Purpose:
   - Calculate donor lifetime value at 3, 6, and 12 months
   - Understand how donor value accumulates over time
--------------------------------------------------------- */


/* ---------------------------------------------------------
   Step 1: Identify each donor’s first donation date
   Description: Establishes the starting point for LTV calculations
--------------------------------------------------------- */
WITH first_donation AS (
    SELECT
        donor_id,
        MIN(donation_date) AS first_donation_date
    FROM donations
    GROUP BY donor_id
)
SELECT *
FROM first_donation
ORDER BY donor_id;


/* ---------------------------------------------------------
   Step 2: Build donation timeline relative to first donation
   Description: Calculates days since first donation for every transaction
--------------------------------------------------------- */
WITH first_donation AS (
    SELECT
        donor_id,
        MIN(donation_date) AS first_donation_date
    FROM donations
    GROUP BY donor_id
),
donation_timeline AS (
    SELECT
        d.donor_id,
        d.donation_date,
        d.donation_amount,
        f.first_donation_date,
        (d.donation_date - f.first_donation_date) AS days_since_first_donation
    FROM donations d
    JOIN first_donation f
        ON d.donor_id = f.donor_id
)
SELECT *
FROM donation_timeline
ORDER BY donor_id, donation_date;


/* ---------------------------------------------------------
   Step 3: Calculate donor-level LTV at 3, 6, and 12 months
   Description: Aggregates donation value within defined time windows
--------------------------------------------------------- */
WITH first_donation AS (
    SELECT
        donor_id,
        MIN(donation_date) AS first_donation_date
    FROM donations
    GROUP BY donor_id
),
donation_timeline AS (
    SELECT
        d.donor_id,
        d.donation_date,
        d.donation_amount,
        (d.donation_date - f.first_donation_date) AS days_since_first_donation
    FROM donations d
    JOIN first_donation f
        ON d.donor_id = f.donor_id
)
SELECT
    donor_id,
    SUM(CASE WHEN days_since_first_donation <= 90  THEN donation_amount ELSE 0 END)  AS ltv_3_months,
    SUM(CASE WHEN days_since_first_donation <= 180 THEN donation_amount ELSE 0 END) AS ltv_6_months,
    SUM(CASE WHEN days_since_first_donation <= 365 THEN donation_amount ELSE 0 END) AS ltv_12_months
FROM donation_timeline
GROUP BY donor_id
ORDER BY donor_id;


/* ---------------------------------------------------------
   Step 4: Calculate average LTV across all donors
   Description: Produces executive-level summary metrics
--------------------------------------------------------- */
WITH first_donation AS (
    SELECT
        donor_id,
        MIN(donation_date) AS first_donation_date
    FROM donations
    GROUP BY donor_id
),
donation_timeline AS (
    SELECT
        d.donor_id,
        d.donation_amount,
        (d.donation_date - f.first_donation_date) AS days_since_first_donation
    FROM donations d
    JOIN first_donation f
        ON d.donor_id = f.donor_id
),
donor_ltv AS (
    SELECT
        donor_id,
        SUM(CASE WHEN days_since_first_donation <= 90  THEN donation_amount ELSE 0 END)  AS ltv_3_months,
        SUM(CASE WHEN days_since_first_donation <= 180 THEN donation_amount ELSE 0 END) AS ltv_6_months,
        SUM(CASE WHEN days_since_first_donation <= 365 THEN donation_amount ELSE 0 END) AS ltv_12_months
    FROM donation_timeline
    GROUP BY donor_id
)
SELECT
    ROUND(AVG(ltv_3_months), 2)  AS avg_ltv_3_months,
    ROUND(AVG(ltv_6_months), 2)  AS avg_ltv_6_months,
    ROUND(AVG(ltv_12_months), 2) AS avg_ltv_12_months
FROM donor_ltv;
