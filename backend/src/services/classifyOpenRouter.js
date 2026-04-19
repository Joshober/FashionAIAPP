import sharp from 'sharp';
import { openrouterChat } from './openrouter.js';
import { parseJsonFromModelText } from '../utils/parseJsonBlock.js';

const CLASSIFY_VISION_INSTRUCTION = `You classify a single garment in a photo for a wardrobe app.
Reply with ONLY valid JSON (no markdown). Shape:
{"clase_nombre":"short English label e.g. T-shirt, Sneaker, Jeans, Coat",
"tipo":"one of: superior, inferior, zapatos, abrigo, vestido, bolso",
"color":"Spanish color word: negro, blanco, gris, azul, rojo, verde, amarillo, naranja, rosa, beige, marrón, violeta, multicolor, desconocido",
"confianza":0-1,
"top3":[{"label":"English class","confianza":0-1},{"label":"...","confianza":0-1}]}

Rules: pick the single main garment. tipo must match slot (superior=shirts/tops, inferior=pants/skirts, zapatos=footwear, abrigo=outer layers, vestido=dress, bolso=bag). top3 has up to 3 English alternatives sorted by confidence.`;

/**
 * Vision-only garment classification when the ViT/HF endpoint fails.
 * @param {import('../config.types.js').AppConfig} config
 * @param {Buffer} buffer
 * @returns {Promise<Record<string, unknown>>}
 */
export async function classifyGarmentWithOpenRouter(config, buffer) {
  const jpeg = await sharp(buffer)
    .rotate()
    .resize(1024, 1024, { fit: 'inside' })
    .jpeg({ quality: 88 })
    .toBuffer();
  const dataUrl = `data:image/jpeg;base64,${jpeg.toString('base64')}`;

  const data = await openrouterChat(config, {
    model: config.openrouterModel,
    response_format: { type: 'json_object' },
    messages: [
      { role: 'system', content: CLASSIFY_VISION_INSTRUCTION },
      {
        role: 'user',
        content: [
          { type: 'text', text: 'Classify the dominant garment for wardrobe tagging.' },
          { type: 'image_url', image_url: { url: dataUrl } },
        ],
      },
    ],
  });

  const content = data?.choices?.[0]?.message?.content || '';
  const parsed = parseJsonFromModelText(content);
  if (!parsed || typeof parsed !== 'object') {
    const err = new Error('OpenRouter classify: invalid JSON');
    // @ts-ignore
    err.status = 502;
    throw err;
  }
  return /** @type {Record<string, unknown>} */ (parsed);
}
