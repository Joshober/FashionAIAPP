## Goal

Freeze and document HTTP contracts for HF Space, OpenRouter, and auth expectations in `backend/README.md` or [docs/CONTRACTS.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/CONTRACTS.md). Add integration-style tests with **mocked** outbound HTTP (e.g. mocked axios) for classify and OpenRouter paths so CI does not call real services or require secrets.

## Acceptance criteria

- [ ] Contract doc covers: HF multipart field `imagen`, response shape / `top3` merge behavior; OpenRouter `POST .../chat/completions` headers and body; Auth0 Bearer optional + anonymous fallback.
- [ ] Tests use fixtures for HF and OpenRouter responses; no real API keys in repo (use `.env.example` placeholders only).
- [ ] Classify path test asserts mapping to `clase_nombre` / `confianza` / `tipo` as applicable.
- [ ] OpenRouter path test asserts request shape and response handling (including error cases if feasible).

## References

- Complements all backend issues; land after or alongside feature routes so tests target real handlers.

## Dependencies

Implement against stable route handlers from prior backend issues (classify, mirror, or chat as applicable).
