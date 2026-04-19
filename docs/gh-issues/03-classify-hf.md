## Goal

Implement garment classification by proxying the configured Hugging Face Space only: multipart `form-data` with field `imagen`, defensive parsing of `top3` vs top-level placeholders, mapping ViT class names to wardrobe slot via `vitClassToTipo`, optional `POST /api/classify/vit-base64`, HEIC→JPEG when needed, and server-side color fallback with `sharp` when the ML response lacks reliable color.

## Acceptance criteria

- [ ] `POST` multipart classify forwards to allowlisted `ML_SERVICE_URL` / `ML_VIT_SERVICE_URL` only (no arbitrary URLs).
- [ ] Request field name `imagen` matches HF Space contract; response maps to `clase_nombre` / `confianza` with merge logic for `top3[0]` vs placeholders.
- [ ] `vitClassToTipo` maps ViT labels to `tipo` for the wardrobe model.
- [ ] Optional `vit-base64` path with payload limits documented.
- [ ] HEIC handling via `heic-convert` + `sharp` where applicable.
- [ ] If ML color missing/unknown, derive hue bucket server-side with `sharp` (no extra vision API for that step).

## References

- HF outbound calls use server-side keys only (never in Flutter).
- Contract row for HF in roadmap: document in `backend/README.md` or [docs/CONTRACTS.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/CONTRACTS.md).

## Dependencies

Requires backend skeleton; Mongo models optional for classify-only routes but typically follows [02-mongo-auth.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/gh-issues/02-mongo-auth.md) for persistence integration.
