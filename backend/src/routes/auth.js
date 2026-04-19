import { Router } from 'express';
import jwt from 'jsonwebtoken';
import crypto from 'node:crypto';

/** @param {import('../config.types.js').AppConfig} config */
export function authRouter(config) {
  const r = Router();

  r.post('/signin', (req, res) => {
    if (!config.jwtSecret) {
      return res.status(503).json({ error: 'JWT_SECRET is not configured on the server' });
    }
    const { email, password } = req.body || {};
    if (typeof email !== 'string' || typeof password !== 'string') {
      return res.status(400).json({ error: 'email and password are required' });
    }
    const e = email.trim().toLowerCase();
    if (!e || !password) {
      return res.status(400).json({ error: 'email and password are required' });
    }

    const expectedEmail = (process.env.SIMPLE_AUTH_EMAIL || '').trim().toLowerCase();
    const expectedPassword = process.env.SIMPLE_AUTH_PASSWORD || '';
    if (expectedEmail && expectedPassword) {
      if (e !== expectedEmail || password !== expectedPassword) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }
    } else if (password.length < 4) {
      return res.status(400).json({ error: 'password must be at least 4 characters' });
    }

    const sub =
      'local:' + crypto.createHash('sha256').update(e).digest('hex').slice(0, 32);
    const access_token = jwt.sign({ sub }, config.jwtSecret, {
      algorithm: 'HS256',
      expiresIn: '30d',
    });
    res.json({ access_token });
  });

  return r;
}
