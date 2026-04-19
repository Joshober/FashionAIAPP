import { Router } from 'express';
import multer from 'multer';
import { classifyVitMultipart, classifyVitBase64Json } from '../services/hfClassify.js';

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 15 * 1024 * 1024 },
});

/** @param {import('../config.types.js').AppConfig} config */
export function classifyRouter(config) {
  const r = Router();

  r.post('/vit', upload.single('imagen'), async (req, res, next) => {
    try {
      if (!req.file?.buffer) {
        return res.status(400).json({ error: 'Missing multipart field imagen' });
      }
      const norm = await classifyVitMultipart(config, req.file.buffer, req.file.originalname);
      res.json(norm);
    } catch (e) {
      next(e);
    }
  });

  r.post('/vit-base64', async (req, res, next) => {
    try {
      const raw = req.body?.imagen || req.body?.image || req.body?.data;
      if (typeof raw !== 'string') {
        return res.status(400).json({ error: 'Expected JSON { imagen: base64 or data URL }' });
      }
      if (raw.length > config.maxVitBase64PayloadChars) {
        return res.status(413).json({ error: 'Payload too large' });
      }
      const b64 = raw.includes(',') ? raw.split(',')[1] : raw;
      const norm = await classifyVitBase64Json(config, b64);
      res.json(norm);
    } catch (e) {
      next(e);
    }
  });

  return r;
}
