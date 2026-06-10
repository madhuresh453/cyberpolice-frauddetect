# Indexing Strategy

Required lookup fields are indexed across the MongoDB document models:

- `phone_number`
- `upi_id`
- `risk_score`
- `created_at`
- `status`
- `report_id`
- `case_id`

Auth-specific indexes:

- `users.email` unique
- `users.phone_number` unique
- `sessions.refresh_token_hash` unique
- `sessions.user_id + status + created_at`
- `api_keys.key_hash` unique
- `api_keys.key_prefix` unique
- `roles.name` unique
- `permissions.code` unique
