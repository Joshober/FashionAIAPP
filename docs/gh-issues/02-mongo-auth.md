## Goal

Add MongoDB via Mongoose with models aligned to the product spec (**Prenda**, **Outfit**, **UserProfile**), optional Auth0 JWT verification with anonymous fallback, and enforce tenant scoping via `getUserId(req)` and `userFilter(userId)` on every database read/write.

## Acceptance criteria

- [ ] Mongoose connection using `MONGODB_URI` and optional `MONGODB_DB_NAME`.
- [ ] **Prenda** schema: `tipo`, `clase_nombre`, `color`, `confianza`, `ocasion[]`, `imagen_url`, `userId` (plus timestamps as appropriate).
- [ ] **Outfit** schema with references to Prendas; **UserProfile** for preferences and assistant context.
- [ ] Middleware: when `Authorization: Bearer` is present and valid Auth0 JWT, resolve user `sub`; otherwise treat as `anonymous` (or equivalent documented behavior).
- [ ] Helper `userFilter(userId)` used consistently so no cross-user data access.
- [ ] No secrets in client; Auth0 issuer/audience from server env only.

## References

- Follows [01-backend-skeleton.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/gh-issues/01-backend-skeleton.md) scaffold.
- Document env vars in `backend/README.md` or [docs/CONTRACTS.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/CONTRACTS.md) when added.

## Dependencies

Requires backend skeleton in place (Express app and route mounts).
