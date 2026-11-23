-- M2: service categories shown as cards on the customer app home screen.
-- Money is stored as integer paise. The customer app shows whole rupees, so the API
-- returns paise / 100 and the whole-rupee check below keeps that conversion lossless.
-- UI-only data (icon, colours, photo, crop focus) intentionally stays in the app.

CREATE TABLE service_categories (
    id                   uuid          PRIMARY KEY,
    slug                 varchar(40)   NOT NULL,             -- stable public id, e.g. 'full-day'
    title                varchar(80)   NOT NULL,
    tagline              varchar(160)  NOT NULL,
    price_paise          integer       NOT NULL,
    original_price_paise integer       NOT NULL,             -- shown struck through
    rating               numeric(2,1)  NOT NULL,
    display_order        integer       NOT NULL,
    active               boolean       NOT NULL DEFAULT true,
    created_at           timestamptz   NOT NULL DEFAULT now(),
    updated_at           timestamptz   NOT NULL DEFAULT now(),
    CONSTRAINT uq_service_categories_slug UNIQUE (slug),
    CONSTRAINT chk_service_categories_slug CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
    CONSTRAINT chk_service_categories_title CHECK (char_length(btrim(title)) >= 1),
    CONSTRAINT chk_service_categories_tagline CHECK (char_length(btrim(tagline)) >= 1),
    CONSTRAINT chk_service_categories_price CHECK (price_paise >= 0),
    CONSTRAINT chk_service_categories_original CHECK (original_price_paise >= price_paise),
    CONSTRAINT chk_service_categories_whole_rupees
        CHECK (price_paise % 100 = 0 AND original_price_paise % 100 = 0),
    CONSTRAINT chk_service_categories_rating CHECK (rating >= 0 AND rating <= 5),
    CONSTRAINT chk_service_categories_order CHECK (display_order >= 0)
);

-- Serves the only read path: active rows in display order.
CREATE INDEX ix_service_categories_active_order ON service_categories (display_order, slug) WHERE active;
