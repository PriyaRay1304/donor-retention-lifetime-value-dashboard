/* ---------------------------------------------------------
   Time to Second Donation Analysis
   Purpose:
   - Identify how long it takes donors to return after
     their first donation
--------------------------------------------------------- */

/* ---------------------------------------------------------
   Step 1: Rank donations per donor
--------------------------------------------------------- */
WITH ranked_donations AS (
    SELECT
        donor_id,
        donation_date,
        donation_amount,
        ROW_NUMBER() OVER (
            PARTITION BY donor_id
            ORDER BY donation_date
        ) AS donation_rank
    FROM donations
)
SELECT *
FROM ranked_donations
ORDER BY donor_id, donation_rank;

/* ---------------------------------------------------------
   Step 2: Calculate days between first and second donation
--------------------------------------------------------- */
WITH ranked_donations AS (
    SELECT
        donor_id,
        donation_date,
        ROW_NUMBER() OVER (
            PARTITION BY donor_id
            ORDER BY donation_date
        ) AS donation_rank
    FROM donations
),
first_second AS (
    SELECT
        donor_id,
        MAX(CASE WHEN donation_rank = 1 THEN donation_date END) AS first_donation_date,
        MAX(CASE WHEN donation_rank = 2 THEN donation_date END) AS second_donation_date
    FROM ranked_donations
    GROUP BY donor_id
)
SELECT
    donor_id,
    first_donation_date,
    second_donation_date,
    (second_donation_date - first_donation_date) AS days_to_second_donation
FROM first_second
WHERE second_donation_date IS NOT NULL
ORDER BY days_to_second_donation;

/* ---------------------------------------------------------
   Step 3: Summary metrics for time to second donation
--------------------------------------------------------- */
WITH ranked_donations AS (
    SELECT
        donor_id,
        donation_date,
        ROW_NUMBER() OVER (
            PARTITION BY donor_id
            ORDER BY donation_date
        ) AS donation_rank
    FROM donations
),
first_second AS (
    SELECT
        donor_id,
        MAX(CASE WHEN donation_rank = 1 THEN donation_date END)
