## Goal

Build Flutter screens and navigation until feature parity with the former SPA concept (not line-by-line port): Wardrobe (grid/list, upload, filters), garment detail (occasions, reclassify), outfit generator + saved outfits + detail, Mirror (preview + analyze-frame; optional `vit-base64` fast path), wardrobe chat (+ optional voice if backend exposes guarded audio routes), Settings synced with `GET`/`PATCH /api/me`.

## Acceptance criteria

- [ ] Navigation structure covers all primary flows above.
- [ ] Screens call the shared API client from [08-flutter-integration.md](./08-flutter-integration.md); handle loading and error states consistently.
- [ ] Upload uses multipart to backend Prendas endpoint; images display from returned `imagen_url`.
- [ ] Settings screen reads/writes `/api/me` merged profile.
- [ ] README or in-app dev notes describe how to point the app at a dev API.

## References

- [lib/main.dart](../../lib/main.dart) and new files under `lib/`.

## Dependencies

Requires API client + auth integration; backend endpoints should exist for each screen (can land incrementally behind feature flags if needed).
