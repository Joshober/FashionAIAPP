# Fashion AI backend

Express + MongoDB API for the Fashion AI Flutter app. Proxies **Hugging Face** classification and **OpenRouter** LLM/audio; never expose API keys to clients.

## Run locally

```bash
cd backend
npm install
cp ../.env.example ../.env   # or set env vars another way
npm run dev
```

Default port **4000**. Static wardrobe images are served from `/uploads/...` (paths namespaced by `userId`).

## Environment

See [`.env.example`](../.env.example) in the repo root for variable names. Important groups:

- **Mongo**: `MONGODB_URI`, optional `MONGODB_DB_NAME`
- **CORS**: `ALLOWED_ORIGINS` (comma-separated; supports `http://localhost:*` patterns)
- **Auth0** (optional): `AUTH0_DOMAIN`, `AUTH0_AUDIENCE` — when set, JWTs are verified; otherwise tokens are only decoded for `sub` (dev convenience)
- **HF**: `ML_SERVICE_URL` / `ML_VIT_SERVICE_URL` — must stay on the allowlisted Space URL
- **OpenRouter**: `OPENROUTER_API_KEY`, models, `MAX_AUDIO_BASE64_CHARS`, `MAX_TTS_CHARS`

## Route prefixes

Mounted under `/api`: health, `classify`, `prendas`, `outfits`, `me`, `chat`, `mirror`, `model`.
