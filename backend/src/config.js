/** Hugging Face Space for ViT / classify (not configurable via env). */
export const HF_VIT_SPACE_URL = 'https://alvaro05-vit-fashion-api.hf.space';

/**
 * @returns {import('./config.types.js').AppConfig}
 */
export function loadConfig() {
  const originsRaw = process.env.ALLOWED_ORIGINS || 'http://localhost:*,http://127.0.0.1:*';
  const port = Number(process.env.PORT || 4000);
  const hfVit = HF_VIT_SPACE_URL.replace(/\/$/, '');

  return {
    port,
    mongodbUri: process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/fashion_ai',
    mongodbDbName: process.env.MONGODB_DB_NAME || undefined,
    allowedOrigins: originsRaw.split(',').map((s) => s.trim()).filter(Boolean),
    auth0Domain: process.env.AUTH0_DOMAIN || '',
    auth0Audience: process.env.AUTH0_AUDIENCE || '',
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
