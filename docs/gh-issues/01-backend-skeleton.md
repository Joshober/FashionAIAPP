## Goal

Scaffold a new `backend/` Express service with environment loading, a single CORS policy that allows Flutter dev/prod origins and the `Authorization` header (Bearer-first), and a clear route mount structure for the Fashion AI API. Include a static `/uploads` (or storage adapter stub) so later upload routes have a predictable public path.

## Acceptance criteria

- [ ] `backend/package.json` with start/dev scripts and required runtime dependencies for Express + CORS + env loading.
- [ ] App entry (`app.js` or `server.js`) loads configuration from environment (no secrets committed; document placeholders in `.env.example` at repo root when that file exists).
- [ ] Routes mounted under prefixes: `/api/prendas`, `/api/classify`, `/api/outfits`, `/api/me`, `/api/mirror`, `/api/chat` (handlers may be stubs that return 501 or empty JSON until later issues).
- [ ] Static `/uploads` (or documented stub) with namespacing strategy noted in code comments or `backend/README.md`.
- [ ] CORS allows configured origins and supports `Authorization`.

## References

- Root Flutter app: [pubspec.yaml](https://github.com/Joshober/FashionAIAPP/blob/main/pubspec.yaml), [lib/main.dart](https://github.com/Joshober/FashionAIAPP/blob/main/lib/main.dart).
- Plan: first backend milestone before Mongo and classification.

## Dependencies

None (first backend issue).
