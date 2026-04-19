import axios from 'axios';

/**
 * @param {import('../config.types.js').AppConfig} config
 * @param {Record<string, unknown>} body
 */
export async function openrouterChat(config, body) {
  if (!config.openrouterApiKey) {
    const err = new Error('OpenRouter not configured');
    // @ts-ignore
    err.status = 503;
    throw err;
  }
  const url = `${config.openrouterBaseUrl}/chat/completions`;
  const { data } = await axios.post(url, body, {
    timeout: 120000,
    headers: {
      Authorization: `Bearer ${config.openrouterApiKey}`,
      'HTTP-Referer': 'https://github.com/FashionAIAPP',
      'X-Title': 'Fashion AI API',
    },
  });
  return data;
}

/**
 * @param {string} text
 */
export function stripAccidentalIds(text) {
  if (!text) return '';
  return text.replace(/\b[a-f0-9]{24}\b/gi, '[id]');
}
