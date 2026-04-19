## Goal

Implement **Mirror** and **Chat** against OpenRouter from the server only: mirror text and multimodal analyze-frame with strict JSON system prompts, parse JSON (strip markdown fences if present), validate mirror image URLs against an allowlist before forwarding; chat loads wardrobe + profile context for prompts without leaking raw Mongo `_id` values; sanitize assistant replies to strip accidental ID leaks. Optional STT/TTS routes with strict payload limits if audio is in scope.

## Acceptance criteria

- [ ] `POST /api/mirror/analyze` and `POST /api/mirror/analyze-frame` call `OPENROUTER_BASE_URL` `/chat/completions` with `Authorization: Bearer` server key.
- [ ] Mirror responses parsed as JSON; invalid output handled gracefully.
- [ ] Image references: data URL or allowlisted HTTP only (document rules in contracts).
- [ ] Chat builds context from Prenda + UserProfile using formatted wardrobe text (no raw `_id` in prompts).
- [ ] Post-processing sanitization on assistant messages.
- [ ] If audio routes exist: enforce `MAX_AUDIO_BASE64_CHARS` / `MAX_TTS_CHARS` (or equivalent) and document.

## References

- OpenRouter contract documented in `backend/README.md` or [docs/CONTRACTS.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/CONTRACTS.md).
- Flutter must never ship `OPENROUTER_API_KEY`.

## Dependencies

Prendas and `/api/me` data paths should exist for rich context ([05-outfits-me.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/gh-issues/05-outfits-me.md), [04-prendas-crud.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/gh-issues/04-prendas-crud.md)).
