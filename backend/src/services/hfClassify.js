import axios from 'axios';
import FormData from 'form-data';
import { normalizeClassifyResponse } from '../utils/classifyNormalize.js';
import { roughColorFromBuffer } from '../utils/imageColor.js';
import { classifyGarmentWithOpenRouter } from './classifyOpenRouter.js';

/** @param {import('../config.types.js').AppConfig} config */
export async function classifyVitMultipart(config, buffer, originalname) {
  try {
    const form = new FormData();
    form.append('imagen', buffer, { filename: originalname || 'upload.jpg' });

    const url = `${config.mlVitServiceUrl}/classify-vit`;
    const { data } = await axios.post(url, form, {
      headers: form.getHeaders(),
      timeout: 120000,
      maxContentLength: Infinity,
      maxBodyLength: Infinity,
    });

    const norm = normalizeClassifyResponse(data && typeof data === 'object' ? data : {});
    if (!norm.color && buffer?.length) {
      norm.color = await roughColorFromBuffer(buffer);
    }
    return norm;
  } catch (mlErr) {
    if (!config.openrouterApiKey) throw mlErr;
    try {
      console.warn('[classify] ViT upstream failed; using OpenRouter vision fallback:', mlErr?.message || mlErr);
      const raw = await classifyGarmentWithOpenRouter(config, buffer);
      const norm = normalizeClassifyResponse(raw && typeof raw === 'object' ? raw : {});
      if (!norm.color && buffer?.length) {
        norm.color = await roughColorFromBuffer(buffer);
      }
      return norm;
    } catch (orErr) {
      console.warn('[classify] OpenRouter fallback failed:', orErr?.message || orErr);
      throw mlErr;
    }
  }
}

/** @param {import('../config.types.js').AppConfig} config */
export async function classifyVitBase64Json(config, base64Payload) {
  const url = `${config.mlVitServiceUrl}/classify-vit`;
  const buffer = Buffer.from(base64Payload, 'base64');
  return classifyVitMultipart(config, buffer, 'frame.jpg');
}
