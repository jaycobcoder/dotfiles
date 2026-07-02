# Test Scope

- **Test CUD only.** Read (queries) are excluded from this convention.
- Each CUD method must cover the following cases:

| Operation | Required cases |
|-----------|----------------|
| Create | success, validation failure, duplicate (unique constraint) |
| Update | success, non-existent entity, optimistic-lock conflict (if applicable) |
| Delete | success, non-existent entity, related-data constraint (if applicable) |
