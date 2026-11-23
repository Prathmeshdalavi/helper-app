# HerCare API contract, milestone 2 (service catalogue)

Source of truth: the customer app, `mobile/customer_app/lib/features/services/` and
`features/home/presentation/widgets/service_sections.dart`. The home screen renders the
eight cards of `DemoServices.categories` in that order, then a fixed "Explore more" row.

## Endpoint

`GET /api/v1/catalog/categories`

- Auth: valid access token (any role). No token or a bad token returns 401 in the standard envelope.
- No parameters. The list is small (8) and not paginated; extra query parameters are ignored.
- Read only: other methods return 405.

```json
{
  "success": true,
  "data": [
    { "id": "cooking", "title": "Cooking", "tagline": "Fresh home-style meals",
      "price": 249, "originalPrice": 349, "rating": 4.8 }
  ],
  "timestamp": "2026-11-23T10:30:00Z"
}
```

Each item has exactly these six fields. `price` and `originalPrice` are whole rupees (JSON
integers, the app prints `₹249` and strikes through `₹349`); `rating` is a number with one
decimal. Order is the display order (`display_order`, then `slug`). Inactive categories are
not returned. An empty catalogue returns `"data": []`.

## Frontend field mapping

| Flutter `ServiceCategory` field | Source | Notes |
|---|---|---|
| `id` | API `id` (slug) | Stable. Also the key the app uses to attach local UI data |
| `title`, `tagline` | API | |
| `price`, `originalPrice` | API | Rupees. Stored as paise in the database |
| `rating` | API | Shown with one decimal (`toStringAsFixed(1)`) |
| `icon`, `tint`, `accent`, `image`, `focus` | **App only** | Not in the API. Match by `id` |
| Order of `DemoServices.categories` | API array order | |
| "Explore more" row and its photos | **App only** | Not a category |

## The eight categories (seeded by V4, copied from `demo_services.dart`)

| # | id | title | tagline | price | original | rating |
|---|---|---|---|---|---|---|
| 1 | cooking | Cooking | Fresh home-style meals | 249 | 349 | 4.8 |
| 2 | cleaning | Cleaning | Floors, kitchen and dusting | 149 | 229 | 4.9 |
| 3 | baby | Baby care | Gentle, trained caregivers | 299 | 399 | 4.9 |
| 4 | pets | Pet care | Walks, play and feeding | 149 | 199 | 4.8 |
| 5 | elder | Elder care | Kind everyday support | 299 | 399 | 4.9 |
| 6 | laundry | Laundry | Wash, dry and fold | 199 | 299 | 4.8 |
| 7 | full-day | Full day | A helper for the whole day | 699 | 899 | 4.7 |
| 8 | monthly | Monthly | Same helper, every visit | 2999 | 3999 | 4.8 |

## Database

`V3__catalog_categories.sql` creates `service_categories` (`id uuid`, `slug`, `title`,
`tagline`, `price_paise`, `original_price_paise`, `rating numeric(2,1)`, `display_order`,
`active`, timestamps) with checks: slug format, non-blank text, price >= 0, original >=
price, whole-rupee amounts, rating 0 to 5, display order >= 0; unique `slug`; partial index
`(display_order, slug) WHERE active`. `V4__seed_categories.sql` inserts the eight rows.

## What the app must still do (not done, frontend is read-only for this task)

1. Replace `DemoServices.categories` with a call to this endpoint, with the access token.
2. Keep icon, tint, accent, photo and focus locally, keyed by `id`. Decide what to show for an
   `id` it has no local assets for (the server can add categories later).
3. Handle loading, empty (`[]`) and error states, and 401 (refresh the token, then retry).
