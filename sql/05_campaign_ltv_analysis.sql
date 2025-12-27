/* ---------------------------------------------------------
   Campaign-Level LTV Analysis
   Purpose:
   - Attribute donor lifetime value to acquisition campaigns
   - Identify high-quality fundraising channels
--------------------------------------------------------- */ 


/* ---------------------------------------------------------
   Step 1: Identify each donor’s acquisition campaign
--------------------------------------------------------- */
WITH first_donation AS (
    SELECT
        donor_id,
        MIN(donation_date) AS first_donation_date
    FROM donations
    GROUP BY donor_id
),
acquisition_campaign AS (
    SELECT
        d.donor_id,
        d.campaign_id
    FROM donations d
    JOIN first_donation f
        ON d.donor_id = f.donor_id
       AND d.donation_date = f.first_donation_date
)
SELECT *
FROM acquisition_campaign
ORDER BY donor_id;


/* ---------------------------------------------------------
   Step 2: Calculate donor LTV (12 months)
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
        SUM(
            CASE
                WHEN days_since_first_donation <= 365
                THEN donation_amount
                ELSE 0
            END
        ) AS ltv_12_months
    FROM donation_timeline
    GROUP BY donor_id
)
SELECT *
FROM donor_ltv
ORDER BY donor_id;


/* ---------------------------------------------------------
   Step 3: Campaign-level LTV attribution
   Description: Aggregates donor LTV by acquisition campaign type
--------------------------------------------------------- */
WITH first_donation AS (
    SELECT
        donor_id,
        MIN(donation_date) AS first_donation_date
    FROM donations
    GROUP BY donor_id
),
acquisition_campaign AS (
    SELECT
        d.donor_id,
        d.campaign_id
    FROM donations d
    JOIN first_donation f
        ON d.donor_id = f.donor_id
       AND d.donation_date = f.first_donation_date
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
        SUM(
            CASE
                WHEN days_since_first_donation <= 365
                THEN donation_amount
                ELSE 0
            END
        ) AS ltv_12_months
    FROM donation_timeline
    GROUP BY donor_id
)
SELECT
    c.campaign_type,
    COUNT(DISTINCT ac.donor_id) AS total_donors,
    ROUND(AVG(dl.ltv_12_months), 2) AS avg_ltv_12_months,
    ROUND(SUM(dl.ltv_12_months), 2) AS total_ltv_12_months
FROM acquisition_campaign ac
JOIN donor_ltv dl
    ON ac.donor_id = dl.donor_id
JOIN campaigns c
    ON ac.campaign_id = c.campaign_id
GROUP BY c.campaign_type
ORDER BY avg_ltv_12_months DESC;

