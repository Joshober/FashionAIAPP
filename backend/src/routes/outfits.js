import { Router } from 'express';
import mongoose from 'mongoose';
import { Outfit } from '../models/Outfit.js';
import { Prenda } from '../models/Prenda.js';
import { UserProfile } from '../models/UserProfile.js';
import { userFilter } from '../utils/userScope.js';
import { recommendOutfits } from '../services/recommend.js';

/** @param {import('../config.types.js').AppConfig} config */
export function outfitsRouter(config) {
  const r = Router();

  // Static paths must precede `/:id` so `/recommend` is not parsed as an ObjectId route.
  r.get('/recommend', async (req, res, next) => {
    try {
      const prefs = {};
      for (const [k, v] of Object.entries(req.query)) {
        prefs[k] = v;
      }
      const prendas = await Prenda.find(userFilter(req.userId)).lean();
      const profile = await UserProfile.findOne(userFilter(req.userId)).lean();
      const mergedPrefs = { ...(profile?.preferences || {}), ...prefs };
      const recs = recommendOutfits(prendas, mergedPrefs, 3);
      res.json({ recommendations: recs });
    } catch (e) {
      next(e);
    }
  });

  r.post('/save', async (req, res, next) => {
    try {
      const body = req.body || {};
      const ids = [
        body.superior_id,
        body.inferior_id,
        body.zapatos_id,
        body.abrigo_id,
        body.vestido_id,
      ].filter(Boolean);

      for (const id of ids) {
        if (!mongoose.isValidObjectId(id)) {
          return res.status(400).json({ error: 'Invalid garment id' });
        }
        const owns = await Prenda.exists({ _id: id, ...userFilter(req.userId) });
        if (!owns) return res.status(400).json({ error: 'Garment not found for user' });
      }

      const doc = await Outfit.create({
        userId: req.userId,
        superior_id: body.superior_id || null,
        inferior_id: body.inferior_id || null,
        zapatos_id: body.zapatos_id || null,
        abrigo_id: body.abrigo_id || null,
        vestido_id: body.vestido_id || null,
        puntuacion: typeof body.puntuacion === 'number' ? body.puntuacion : 0,
        explicacion: typeof body.explicacion === 'string' ? body.explicacion : '',
      });
      res.status(201).json(doc.toObject());
    } catch (e) {
      next(e);
    }
  });

  r.get('/', async (req, res, next) => {
    try {
      const list = await Outfit.find(userFilter(req.userId))
        .sort({ updatedAt: -1 })
        .populate([
          { path: 'superior_id' },
          { path: 'inferior_id' },
          { path: 'zapatos_id' },
          { path: 'abrigo_id' },
          { path: 'vestido_id' },
        ])
        .lean();
      res.json(list);
    } catch (e) {
      next(e);
    }
  });

  r.get('/:id', async (req, res, next) => {
    try {
      if (!mongoose.isValidObjectId(req.params.id)) {
        return res.status(404).json({ error: 'Not found' });
      }
      const doc = await Outfit.findOne({ _id: req.params.id, ...userFilter(req.userId) })
        .populate([
          { path: 'superior_id' },
          { path: 'inferior_id' },
          { path: 'zapatos_id' },
          { path: 'abrigo_id' },
          { path: 'vestido_id' },
        ])
        .lean();
      if (!doc) return res.status(404).json({ error: 'Not found' });
      res.json(doc);
    } catch (e) {
      next(e);
    }
  });

  r.delete('/:id', async (req, res, next) => {
    try {
      if (!mongoose.isValidObjectId(req.params.id)) {
        return res.status(404).json({ error: 'Not found' });
      }
      const doc = await Outfit.findOneAndDelete({ _id: req.params.id, ...userFilter(req.userId) });
      if (!doc) return res.status(404).json({ error: 'Not found' });
      res.json({ ok: true });
    } catch (e) {
      next(e);
    }
  });

  return r;
}
