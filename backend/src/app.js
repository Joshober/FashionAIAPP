import express from 'express';
import path from 'path';
import fs from 'fs';
import cors from 'cors';
import helmet from 'helmet';
import { fileURLToPath } from 'url';
import { authMiddleware } from './middleware/auth.js';
import { healthRouter } from './routes/health.js';
import { classifyRouter } from './routes/classify.js';
import { prendasRouter } from './routes/prendas.js';
import { outfitsRouter } from './routes/outfits.js';
import { meRouter } from './routes/me.js';
import { chatRouter } from './routes/chat.js';
import { mirrorRouter } from './routes/mirror.js';
import { modelRouter } from './routes/model.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/** @param {import('./config.types.js').AppConfig} config */
export function createApp(config) {
  const app = express();

  app.use(helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }));

  const corsOptions = {
    origin(origin, callback) {
      if (!origin) return callback(null, true);
      const ok = config.allowedOrigins.some((pattern) => {
        if (!pattern.includes('*')) return pattern === origin;
        const re = new RegExp(`^${pattern.replace(/\*/g, '.*')}$`);
        return re.test(origin);
      });
      if (ok) return callback(null, true);
      return callback(null, false);
    },
    credentials: true,
    allowedHeaders: ['Authorization', 'Content-Type'],
  };
  app.use(cors(corsOptions));

  app.use(express.json({ limit: '15mb' }));
  app.use(express.urlencoded({ extended: true, limit: '15mb' }));

  const uploadsDir = path.join(__dirname, '..', 'uploads');
  if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });
  app.use('/uploads', express.static(uploadsDir));

  app.use(authMiddleware(config));

  app.use('/api', healthRouter(config));
  app.use('/api/classify', classifyRouter(config));
  app.use('/api/prendas', prendasRouter(config));
  app.use('/api/outfits', outfitsRouter(config));
  app.use('/api/me', meRouter(config));
  app.use('/api/chat', chatRouter(config));
  app.use('/api/mirror', mirrorRouter(config));
  app.use('/api/model', modelRouter(config));

  app.use((err, _req, res, _next) => {
    console.error(err);
    res.status(err.status || 500).json({ error: err.message || 'Internal error' });
  });

  return app;
}
