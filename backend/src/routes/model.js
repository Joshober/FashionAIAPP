import { Router } from 'express';

/** @param {import('../config.types.js').AppConfig} _config */
export function modelRouter(_config) {
  const r = Router();

  r.get('/data-audit', (_req, res) => {
    res.json({
      message: 'Placeholder: add dataset audit asset URL when available.',
      imageUrl: null,
    });
  });

  return r;
}
