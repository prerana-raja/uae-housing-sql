-- Cleaned Dubai property listings (3,435 validated records)
DROP TABLE IF EXISTS listings;

CREATE TABLE listings (
    listing_id         INTEGER PRIMARY KEY,
    price_aed          REAL    NOT NULL CHECK (price_aed > 0),
    area_sqft          REAL    NOT NULL CHECK (area_sqft > 0),
    price_per_sqft     REAL    NOT NULL,
    bedrooms           INTEGER NOT NULL,          -- 0 = studio
    bedroom_label      TEXT    NOT NULL,
    bathrooms          INTEGER NOT NULL,
    property_type      TEXT    NOT NULL,
    location           TEXT    NOT NULL,          -- community / area name
    project_name       TEXT    NOT NULL,
    furnishing         TEXT    NOT NULL,          -- 'Furnished' | 'Unfurnished'
    completion_status  TEXT    NOT NULL,          -- 'Ready' | 'Off-Plan'
    handover           TEXT    NOT NULL,          -- e.g. 'Q4 2026'
    handover_year      INTEGER NOT NULL,
    handover_quarter   TEXT    NOT NULL,
    price_band         TEXT    NOT NULL,          -- '<1M' | '1-2M' | '2-5M' | '5-10M' | '10M+'
    dq_flag            TEXT    NOT NULL           -- 'ok' | 'ready_but_future_handover' | 'non_standard_type'
);

CREATE INDEX idx_listings_location ON listings(location);
CREATE INDEX idx_listings_type     ON listings(property_type);
CREATE INDEX idx_listings_status   ON listings(completion_status);
