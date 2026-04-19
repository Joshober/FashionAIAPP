import { Router } from 'express';
import { UserProfile } from '../models/UserProfile.js';
import { userFilter } from '../utils/userScope.js';

const ALLOWED_PREF_KEYS = new Set([
  'style_preference',
  'formality',
  'palette',
  'climate',
  'notes',
  'avoid',
]);

function defaultPreferences() {
  return {
    style_preference: '',
    formality: 'smart_casual',
    palette: '',
    climate: '',
    notes: '',
    avoid: '',
  };
}

/** @param {import('../config.types.js').AppConfig} _config */
export function meRouter(_config) {
  const r = Router();

  r.get('/preferences', async (req, res, next) => {
    try {
      let profile = await UserProfile.findOne(userFilter(req.userId)).lean();
      if (!profile) {
        profile = {
          userId: req.userId,
          preferences: defaultPreferences(),
        };
      }
      res.json({
        preferences: { ...defaultPreferences(), ...(profile.preferences || {}) },
      });
    } catch (e) {
      next(e);
    }
  });

  r.put('/preferences', async (req, res, next) => {
    try {
      const incoming = req.body?.preferences && typeof req.body.preferences === 'object'
        ? req.body.preferences
        : req.body;
      if (!incoming || typeof incoming !== 'object') {
        return res.status(400).json({ error: 'Expected preferences object' });
      }
      const merged = { ...defaultPreferences() };
      for (const [k, v] of Object.entries(incoming)) {
        if (!ALLOWED_PREF_KEYS.has(k)) continue;
        if (typeof v === 'string') merged[k] = v;
      }
      const doc = await UserProfile.findOneAndUpdate(
        userFilter(req.userId),
        { $setOnInsert: { userId: req.userId }, $set: { preferences: merged } },
        { new: true, upsert: true }
      ).lean();
      res.json({
        preferences: { ...defaultPreferences(), ...(doc?.preferences || {}) },
      });
    } catch (e) {
      next(e);
    }
  });

  return r;
}
