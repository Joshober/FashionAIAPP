import { Router } from 'express';
import axios from 'axios';

/** @param {import('../config.types.js').AppConfig} config */
export function healthRouter(config) {
  const r = Router();

  r.get('/health', (_req, res) => {
    res.json({ ok: true, service: 'fashion-ai-api' });
  });

  r.get('/ml-health', async (_req, res) => {
    try {
      const url = `${config.mlVitServiceUrl}/health`;
      const { data, status } = await axios.get(url, { timeout: 15000, validateStatus: () => true });
      res.status(status < 500 ? 200 : 502).json({ ok: status < 400, upstreamStatus: status, data });
    } catch (e) {
      res.status(502).json({ ok: false, error: String(e?.message || e) });
    }
  });

  return r;
}
