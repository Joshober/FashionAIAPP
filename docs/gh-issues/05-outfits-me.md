## Goal

Implement outfit recommendation and persistence plus user defaults: `GET /api/outfits/recommend` using a server-side rule engine (load by `tipo`, filters, enforce constraints such as top + trouser + sneaker, score with formality + palette + preferences + jitter, return top 3). Save/list/delete outfits with validation that all garment IDs belong to the same `userId`. Expose `GET`/`PATCH /api/me` with merged defaults and sanitized PATCH fields.

## Acceptance criteria

- [ ] `GET /api/outfits/recommend` returns up to 3 outfits without calling OpenRouter (rule engine only).
- [ ] Save/list/delete outfit endpoints validate Prenda ownership via `userId`.
- [ ] `GET /api/me` returns merged UserProfile defaults.
- [ ] `PATCH /api/me` accepts only allowed fields; rejects unknown keys; merges safely.
- [ ] Integration tests or manual checklist documented for happy paths.

## References

- Depends on Prenda data from [04-prendas-crud.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/gh-issues/04-prendas-crud.md).

## Dependencies

Prendas CRUD and user profile model in place.
