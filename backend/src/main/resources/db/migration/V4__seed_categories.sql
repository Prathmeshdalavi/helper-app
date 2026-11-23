-- M2: the eight categories the customer app home screen shows today, copied exactly from
-- mobile/customer_app/lib/features/services/data/demo_services.dart (titles, taglines,
-- prices in rupees x 100, ratings, and the display order of DemoServices.categories).
-- Reference data only; no user data is touched.

INSERT INTO service_categories
    (id, slug, title, tagline, price_paise, original_price_paise, rating, display_order)
VALUES
    (gen_random_uuid(), 'cooking',  'Cooking',   'Fresh home-style meals',       24900,  34900, 4.8, 1),
    (gen_random_uuid(), 'cleaning', 'Cleaning',  'Floors, kitchen and dusting',  14900,  22900, 4.9, 2),
    (gen_random_uuid(), 'baby',     'Baby care', 'Gentle, trained caregivers',   29900,  39900, 4.9, 3),
    (gen_random_uuid(), 'pets',     'Pet care',  'Walks, play and feeding',      14900,  19900, 4.8, 4),
    (gen_random_uuid(), 'elder',    'Elder care','Kind everyday support',        29900,  39900, 4.9, 5),
    (gen_random_uuid(), 'laundry',  'Laundry',   'Wash, dry and fold',           19900,  29900, 4.8, 6),
    (gen_random_uuid(), 'full-day', 'Full day',  'A helper for the whole day',   69900,  89900, 4.7, 7),
    (gen_random_uuid(), 'monthly',  'Monthly',   'Same helper, every visit',    299900, 399900, 4.8, 8)
ON CONFLICT (slug) DO NOTHING;
