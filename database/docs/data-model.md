# Data model (planned, not yet implemented)

Each backend module owns its tables and only reads other modules' data through
their services.

| Module | Planned tables |
|---|---|
| auth | `credentials`, `refresh_tokens`, `otp_challenges` |
| user | `users`, `user_roles` |
| helper | `helpers`, `helper_documents`, `helper_availability` |
| address | `addresses`, `service_areas` |
| catalog | `categories`, `services`, `service_packages` |
| booking | `bookings`, `booking_items`, `booking_status_history` |
| payment | `payments`, `wallets`, `wallet_transactions`, `refunds` |
| offer | `offers`, `offer_redemptions`, `referrals` |
| notification | `device_tokens`, `notifications` |
| support | `faqs`, `support_tickets` |

Booking statuses and roles are defined in `shared/contracts/`.
