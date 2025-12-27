/* ---------------------------------------------------------
   Schema Definition: Donor Retention & LTV Analytics
   Purpose: Define core entities for donors, campaigns, and donations
--------------------------------------------------------- */

/* ---------------------------------------------------------
   Table: donors
   Description: Stores donor-level information
--------------------------------------------------------- */
CREATE TABLE donors (
    donor_id SERIAL PRIMARY KEY,
    signup_date DATE NOT NULL,
    donor_type VARCHAR(50),
    location VARCHAR(100)
);

/* ---------------------------------------------------------
   Table: campaigns
   Description: Represents fundraising campaigns
--------------------------------------------------------- */
CREATE TABLE campaigns (
    campaign_id SERIAL PRIMARY KEY,
    campaign_type VARCHAR(50),
    start_date DATE,
    end_date DATE
);

/* ---------------------------------------------------------
   Table: donations
   Description: Transaction-level donation data
--------------------------------------------------------- */
CREATE TABLE donations (
    donation_id SERIAL PRIMARY KEY,
    donor_id INT REFERENCES donors(donor_id),
    campaign_id INT REFERENCES campaigns(campaign_id),
    donation_date DATE NOT NULL,
    donation_amount NUMERIC(10,2) NOT NULL
);
