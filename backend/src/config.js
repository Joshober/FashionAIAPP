/** Hugging Face Space for ViT / classify (not configurable via env). */
export const HF_VIT_SPACE_URL = 'https://alvaro05-vit-fashion-api.hf.space';

const LOCAL_MONGO_DEFAULT = 'mongodb://127.0.0.1:27017/fashion_ai';

function resolveMongoDbUri() {
  const uri = (process.env.MONGODB_URI || '').trim();
  if (uri) return uri;
  const onRender = process.env.RENDER === 'true';
  if (onRender) {
    throw new Error(
      'MONGODB_URI is not set. Render has no local MongoDB. In the Render Dashboard: ' +
        'Environment → Environment Variables → add MONGODB_URI with your Atlas (or other) connection string, ' +
        'e.g. mongodb+srv://USER:PASS@cluster.mongodb.net/fashion_ai?retryWrites=true&w=majority',
    );
  }
  return LOCAL_MONGO_DEFAULT;
}

/**
 * @returns {import('./config.types.js').AppConfig}
 */
export function loadConfig() {
  const originsRaw = process.env.ALLOWED_ORIGINS || 'http://localhost:*,http://127.0.0.1:*';
  const port = Number(process.env.PORT || 4000);
  const hfVit = HF_VIT_SPACE_URL.replace(/\/$/, '');

  return {
    port,
    mongodbUri: resolveMongoDbUri(),
    mongodbDbName: process.env.MONGODB_DB_NAME || undefined,
    allowedOrigins: originsRaw.split(',').map((s) => s.trim()).filter(Boolean),
    jwtSecret: process.env.JWT_SECRET || '',
    mlServiceUrl: hfVit,
    mlVitServiceUrl: hfVit,
    openrouterApiKey: process.env.OPENROUTER_API_KEY || '',
    openrouterBaseUrl: (process.env.OPENROUTER_BASE_URL || 'https://openrouter.ai/api/v1').replace(/\/$/, ''),
    openrouterModel: process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini',
    openrouterAudioModel: process.env.OPENROUTER_AUDIO_MODEL || 'openai/gpt-4o-audio-preview',
    openrouterSttModel: process.env.OPENROUTER_STT_MODEL || 'openai/gpt-4o-audio-preview',
    openrouterTtsVoice: process.env.OPENROUTER_TTS_VOICE || 'alloy',
    openrouterTtsFormat: process.env.OPENROUTER_TTS_FORMAT || 'wav',
    maxAudioBase64Chars: Number(process.env.MAX_AUDIO_BASE64_CHARS || 8_000_000),
    maxTtsChars: Number(process.env.MAX_TTS_CHARS || 2000),
    prendasMaxPerUser: process.env.PRENDAS_MAX_PER_USER ? Number(process.env.PRENDAS_MAX_PER_USER) : 0,
    maxVitBase64PayloadChars: Number(process.env.MAX_VIT_BASE64_PAYLOAD_CHARS || 12_000_000),
  };
}
