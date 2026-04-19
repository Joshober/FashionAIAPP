import { Router } from 'express';
import jwt from 'jsonwebtoken';
import crypto from 'node:crypto';
import bcrypt from 'bcryptjs';
import { User } from '../models/User.js';

/** @param {import('../config.types.js').AppConfig} config */
export function authRouter(config) {
  const r = Router();

  // ── Sign Up ────────────────────────────────────────────────────────────────
  r.post('/signup', async (req, res) => {
    if (!config.jwtSecret) {
      return res.status(503).json({ error: 'JWT_SECRET is not configured on the server' });
    }
    const { email, password } = req.body || {};
    if (typeof email !== 'string' || typeof password !== 'string') {
      return res.status(400).json({ error: 'email and password are required' });
    }
    const e = email.trim().toLowerCase();
    if (!e) return res.status(400).json({ error: 'email is required' });
    if (password.length < 6) {
      return res.status(400).json({ error: 'password must be at least 6 characters' });
    }

    try {
      const existing = await User.findOne({ email: e });
      if (existing) return res.status(409).json({ error: 'An account with that email already exists' });

      const passwordHash = await bcrypt.hash(password, 12);
      const user = await User.create({ email: e, passwordHash });

      const sub = 'local:' + crypto.createHash('sha256').update(e).digest('hex').slice(0, 32);
      const access_token = jwt.sign({ sub }, config.jwtSecret, {
        algorithm: 'HS256',
        expiresIn: '30d',
      });
      return res.status(201).json({ access_token });
    } catch (err) {
      console.error('signup error', err);
      return res.status(500).json({ error: 'Sign-up failed, please try again' });
    }
  });

  // ── Sign In ────────────────────────────────────────────────────────────────
  r.post('/signin', async (req, res) => {
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

    // First: try DB-registered users.
    try {
      const user = await User.findOne({ email: e });
      if (user) {
        const match = await bcrypt.compare(password, user.passwordHash);
        if (!match) return res.status(401).json({ error: 'Invalid email or password' });

        const sub = 'local:' + crypto.createHash('sha256').update(e).digest('hex').slice(0, 32);
        const access_token = jwt.sign({ sub }, config.jwtSecret, {
          algorithm: 'HS256',
          expiresIn: '30d',
        });
        return res.json({ access_token });
      }
    } catch (err) {
      console.error('signin db error', err);
    }

    // Fallback: legacy env-var single-account mode.
    const expectedEmail = (process.env.SIMPLE_AUTH_EMAIL || '').trim().toLowerCase();
    const expectedPassword = process.env.SIMPLE_AUTH_PASSWORD || '';
    if (expectedEmail && expectedPassword) {
      if (e !== expectedEmail || password !== expectedPassword) {
        return res.status(401).json({ error: 'Invalid email or password' });
      }
    } else if (password.length < 4) {
      return res.status(400).json({ error: 'password must be at least 4 characters' });
    }

    const sub = 'local:' + crypto.createHash('sha256').update(e).digest('hex').slice(0, 32);
    const access_token = jwt.sign({ sub }, config.jwtSecret, {
      algorithm: 'HS256',
      expiresIn: '30d',
    });
    return res.json({ access_token });
  });

  return r;
}
