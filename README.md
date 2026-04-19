# Fashion AI

Flutter mobile client plus Node.js **Express** backend for an AI-assisted wardrobe: garment classification (Hugging Face via backend proxy), outfit recommendations, stylist chat and mirror flows (OpenRouter on the server only), and Auth0 bearer tokens.

## Repository layout

- [`lib/`](lib/) — Flutter app (go_router + Riverpod + Dio).
- [`backend/`](backend/) — REST API under `/api/*`, static files under `/uploads`.
- [`docs/CONTRACTS.md`](docs/CONTRACTS.md) — HTTP contract notes.
- [`.env.example`](.env.example) — environment variable template (no secrets).

## Backend

Prerequisites: **Node 20+**, **MongoDB** reachable at `MONGODB_URI`.

```powershell
cd backend
npm install
# Copy .env.example to repo root .env or backend\.env and set variables
npm run dev
```

API listens on `PORT` (default **4000**). Configure `ALLOWED_ORIGINS` for your Flutter web or dev tooling origins; mobile requests often have no `Origin` header and are still allowed by CORS.

## Flutter

Prerequisites: **Flutter SDK** on your PATH.

The app defaults to the deployed API **`https://fashionai-api-6w7k.onrender.com`** (see [`lib/core/env.dart`](lib/core/env.dart) and [`assets/env/dev.env`](assets/env/dev.env)). Override `API_BASE_URL` in `assets/env/dev.env` or with `--dart-define=API_BASE_URL=http://127.0.0.1:4000` for a local backend.

Optional **Auth0** (public identifiers only in the app): set `AUTH0_DOMAIN`, `AUTH0_CLIENT_ID`, `AUTH0_AUDIENCE`, and `AUTH0_SCHEME` in `assets/env/dev.env`. For Android, you can also set `AUTH0_DOMAIN` / `AUTH0_SCHEME` in `android/local.properties` for manifest placeholders used by the Auth0 SDK.

```powershell
flutter pub get
flutter run
```

On startup the app loads env assets via `flutter_dotenv` (see `lib/main.dart`). `--dart-define=API_BASE_URL=...` still overrides everything for ad-hoc builds.

## Security

Never put `OPENROUTER_API_KEY`, Hugging Face secrets, or Mongo credentials in the Flutter app. Only the backend calls upstream ML/LLM services.
