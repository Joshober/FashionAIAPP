## Goal

Add Flutter dependencies and a central API client that targets `API_BASE_URL` (via `--dart-define` or `flutter_dotenv` for **non-secret** values only). Integrate Auth0 login, store access tokens securely (e.g. `flutter_secure_storage`), and attach `Authorization: Bearer` when logged in. Never embed OpenRouter keys, HF tokens, or other server secrets in the app binary.

## Acceptance criteria

- [ ] HTTP client (`dio` or `http`) configured with base URL from build-time defines or env package.
- [ ] Auth0 Flutter SDK (or equivalent OIDC) wired for domain + client ID (public identifiers only).
- [ ] Token persistence uses secure storage on supported platforms.
- [ ] API client attaches Bearer token when present; behaves per backend contract when anonymous.
- [ ] Document local run flags in [README.md](https://github.com/Joshober/FashionAIAPP/blob/main/README.md) (e.g. sample `--dart-define=API_BASE_URL=...`).

## References

- [pubspec.yaml](https://github.com/Joshober/FashionAIAPP/blob/main/pubspec.yaml), [lib/main.dart](https://github.com/Joshober/FashionAIAPP/blob/main/lib/main.dart).

## Dependencies

Backend should be runnable locally or deployed so integration can be tested (any milestone with health or stub routes is enough to start).
