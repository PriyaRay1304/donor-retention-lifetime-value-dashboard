/* 
   Donor Segmentation Analysis
   Purpose:
   - Classify donors as one-time or repeat donors
   - Quantify retention levels within the donor base
 */

/* ---------------------------------------------------------
   Step 1: Count donations per donor
--------------------------------------------------------- */
SELECT
    CASE
        WHEN donation_count = 1 THEN 'One-time Donor'
        ELSE 'Repeat Donor'
    END AS donor_type,
    COUNT(*) AS number_of_donors
FROM (
    SELECT donor_id, COUNT(*) AS donation_count
    FROM donations
    GROUP BY donor_id
) sub
GROUP BY donor_type;

/* ---------------------------------------------------------
   Step 2: Calculate donor percentages
   Description:
   - Adds percentage contribution of each donor segment
   - Uses a window function for dynamic totals
--------------------------------------------------------- */
WITH donor_counts AS (
    SELECT donor_id, COUNT(*) AS donation_count
    FROM donations
    GROUP BY donor_id
)
SELECT
    CASE
        WHEN donation_count = 1 THEN 'One-time Donor'
        ELSE 'Repeat Donor'
    END AS donor_type,
    COUNT(*) AS number_of_donors,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_donors
FROM donor_counts
GROUP BY donor_type;
