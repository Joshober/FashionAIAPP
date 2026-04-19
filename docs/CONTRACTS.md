# HTTP API contracts

Base URL: the Flutter app sets `API_BASE_URL` (default production: `https://fashionai-api-6w7k.onrender.com`). All paths below are relative to that origin.

## Auth

- When **`Authorization: Bearer <jwt>`** is present and `AUTH0_DOMAIN` + `AUTH0_AUDIENCE` are configured on the server, the JWT is verified and `sub` becomes the tenant `userId`.
- If the header is missing or verification is disabled / fails, requests use `userId = "anonymous"` (still tenant-scoped so anonymous users do not see each other’s data).

## Health

| Method | Path | Response |
|--------|------|----------|
| GET | `/api/health` | `{ "ok": true, "service": "fashion-ai-api" }` |
| GET | `/api/ml-health` | Proxies HF Space `GET /health`; `{ ok, upstreamStatus, data }` style |

## Classification (HF proxy)

| Method | Path | Body | Response (JSON) |
|--------|------|------|-----------------|
| POST | `/api/classify/vit` | `multipart/form-data` field **`imagen`** (file) | `{ tipo, color, clase_nombre, confianza, top3 }` |
| POST | `/api/classify/vit-base64` | JSON `{ "imagen": "<base64 or data URL>" }` | Same as `/vit` |

Server enforces `MAX_VIT_BASE64_PAYLOAD_CHARS` on JSON size.

## Prendas (garments)

| Method | Path | Notes |
|--------|------|--------|
| GET | `/api/prendas` | List for current `userId` |
| GET | `/api/prendas/:id` | 404 if wrong user |
| POST | `/api/prendas/upload` | Multipart field **`imagen`** → saved under `/uploads/<userId>/…`, classified, `Prenda` created |
| POST | `/api/prendas/auto` | JSON `{ imagen_url, tipo?, clase_nombre?, color?, confianza?, ocasion?[] }` |
| PUT | `/api/prendas/:id/ocasion` | JSON `{ ocasion: string[] }` |
| DELETE | `/api/prendas/:id` | Deletes file under `/uploads` when `imagen_url` is local |

`imagen_url` for uploads is a relative path such as `/uploads/<userId>/file.jpg` resolvable as `API_BASE_URL + imagen_url`.

## Outfits

| Method | Path | Notes |
|--------|------|--------|
| GET | `/api/outfits/recommend` | Query string merges with saved user preferences; returns `{ recommendations: [ { superior_id, inferior_id, zapatos_id, abrigo_id?, vestido_id?, puntuacion, explicacion } ] }` |
| POST | `/api/outfits/save` | JSON with garment id strings; validates ownership |
| GET | `/api/outfits` | List (populated garment refs) |
| GET | `/api/outfits/:id` | Detail |
| DELETE | `/api/outfits/:id` | |

## Preferences

| Method | Path | Body | Response |
|--------|------|------|----------|
| GET | `/api/me/preferences` | — | `{ preferences: { style_preference, formality, palette, climate, notes, avoid } }` |
| PUT | `/api/me/preferences` | `{ preferences: { ... } }` or flat allowed keys | Same shape as GET |

Allowed keys: `style_preference`, `formality`, `palette`, `climate`, `notes`, `avoid`.

## Chat

| Method | Path | Body | Response |
|--------|------|------|----------|
| POST | `/api/chat` | `{ message: string }` | `{ reply: string, outfitGeneration: object \| null }` — `outfitGeneration` is merged into recommend query on the client |
| POST | `/api/chat/transcribe` | `{ audio: "<wav base64>" }` | `{ text: string }` |
| POST | `/api/chat/tts` | `{ text: string }` | `{ format: string, audio: "<base64>" }` or 502 if model returns no audio |

Payload limits: `MAX_AUDIO_BASE64_CHARS`, `MAX_TTS_CHARS`.

## Mirror

| Method | Path | Body | Response |
|--------|------|------|----------|
| POST | `/api/mirror/analyze` | `{ prompt: string }` | JSON: `score`, `confidence`, `summary`, `suggestions[]`, `detectedItems[]` |
| POST | `/api/mirror/analyze-frame` | `{ frame: "data:image/jpeg;base64,...", context: object }` | Same shape as analyze |

Only `data:image/(jpeg|jpg|png|webp);base64,...` frame URLs are accepted.

## Model (optional)

| Method | Path | Response |
|--------|------|----------|
| GET | `/api/model/data-audit` | Placeholder JSON until a real asset pipeline exists |

## Flutter alignment

- Query builder: [`lib/utils/outfit_recommend_query.dart`](../lib/utils/outfit_recommend_query.dart)
- Save payload: [`lib/utils/save_outfit_payload.dart`](../lib/utils/save_outfit_payload.dart)
- Mirror context persistence: [`lib/utils/mirror_context.dart`](../lib/utils/mirror_context.dart)
