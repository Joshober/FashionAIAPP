## Goal

Implement **Prendas** CRUD with an upload pipeline: accept image uploads (e.g. Multer to disk or stream to object storage), run the internal classify flow after upload, persist `imagen_url` as a URL the Flutter client can load, namespace stored paths by `userId`, and optionally enforce `PRENDAS_MAX_PER_USER`.

## Acceptance criteria

- [ ] Create, read, update, delete Prenda documents scoped with `userFilter(userId)`.
- [ ] Upload endpoint invokes classification pipeline and persists resulting `tipo`, `clase_nombre`, `color`, `confianza`, `ocasion[]`, `imagen_url`.
- [ ] `imagen_url` is browser/mobile-loadable (public `/uploads/...` or signed URL strategy documented).
- [ ] File paths or object keys namespaced per `userId`.
- [ ] Optional cap: reject or prune when count exceeds `PRENDAS_MAX_PER_USER` if configured.

## References

- Builds on [03-classify-hf.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/gh-issues/03-classify-hf.md) and [02-mongo-auth.md](https://github.com/Joshober/FashionAIAPP/blob/main/docs/gh-issues/02-mongo-auth.md).

## Dependencies

Mongo + auth scoping and classify routes (or internal classify module) should exist before wiring full upload pipeline.
