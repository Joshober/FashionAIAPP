import axios from 'axios';
import FormData from 'form-data';
import { normalizeClassifyResponse } from '../utils/classifyNormalize.js';
import { roughColorFromBuffer } from '../utils/imageColor.js';

/** @param {import('../config.types.js').AppConfig} config */
export async function classifyVitMultipart(config, buffer, originalname) {
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
}

/** @param {import('../config.types.js').AppConfig} config */
export async function classifyVitBase64Json(config, base64Payload) {
  const url = `${config.mlVitServiceUrl}/classify-vit`;
  const buffer = Buffer.from(base64Payload, 'base64');
  return classifyVitMultipart(config, buffer, 'frame.jpg');
}
