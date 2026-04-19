import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { Router } from 'express';
import multer from 'multer';
import mongoose from 'mongoose';
import { Prenda } from '../models/Prenda.js';
import { userFilter } from '../utils/userScope.js';
import { classifyVitMultipart } from '../services/hfClassify.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

function uploadsRoot() {
  return path.join(__dirname, '..', '..', 'uploads');
}

/** @param {import('../config.types.js').AppConfig} config */
export function prendasRouter(config) {
  const r = Router();

  const storage = multer.diskStorage({
    destination: (req, _file, cb) => {
      const dir = path.join(uploadsRoot(), req.userId);
      fs.mkdirSync(dir, { recursive: true });
      cb(null, dir);
    },
    filename: (_req, file, cb) => {
      const ext = path.extname(file.originalname) || '.jpg';
      cb(null, `${Date.now()}-${Math.random().toString(16).slice(2)}${ext}`);
    },
  });

  const upload = multer({
    storage,
    limits: { fileSize: 15 * 1024 * 1024 },
  });

  async function assertPrendaCap(userId) {
    if (!config.prendasMaxPerUser) return;
    const count = await Prenda.countDocuments(userFilter(userId));
    if (count >= config.prendasMaxPerUser) {
      const err = new Error('Maximum garments per user reached');
      // @ts-ignore
      err.status = 403;
      throw err;
    }
  }

  r.get('/', async (req, res, next) => {
    try {
      const list = await Prenda.find(userFilter(req.userId)).sort({ updatedAt: -1 }).lean();
      res.json(list);
    } catch (e) {
      next(e);
    }
  });

  r.post('/upload', upload.single('imagen'), async (req, res, next) => {
    try {
      await assertPrendaCap(req.userId);
      if (!req.file?.path) {
        return res.status(400).json({ error: 'Missing multipart field imagen' });
      }
      const rel = path.relative(uploadsRoot(), req.file.path).split(path.sep).join('/');
      const imagen_url = `/uploads/${rel}`;

      const fsProm = fs.promises;
      const buf = await fsProm.readFile(req.file.path);
      const norm = await classifyVitMultipart(config, buf, req.file.originalname);

      const created = await Prenda.create({
        userId: req.userId,
        imagen_url,
        tipo: norm.tipo,
        clase_nombre: norm.clase_nombre,
        color: norm.color,
        confianza: norm.confianza,
        ocasion: [],
      });
      res.status(201).json(created.toObject());
    } catch (e) {
      next(e);
    }
  });

  r.post('/auto', async (req, res, next) => {
    try {
      await assertPrendaCap(req.userId);
      const {
        imagen_url,
        tipo,
        clase_nombre,
        color,
        confianza,
        ocasion,
      } = req.body || {};

      if (!imagen_url || typeof imagen_url !== 'string') {
        return res.status(400).json({ error: 'imagen_url required' });
      }

      const created = await Prenda.create({
        userId: req.userId,
        imagen_url,
        tipo: typeof tipo === 'string' ? tipo : 'superior',
        clase_nombre: typeof clase_nombre === 'string' ? clase_nombre : '',
        color: typeof color === 'string' ? color : '',
        confianza: typeof confianza === 'number' ? confianza : 0,
        ocasion: Array.isArray(ocasion) ? ocasion.map(String) : [],
      });
      res.status(201).json(created.toObject());
    } catch (e) {
      next(e);
    }
  });

  r.get('/:id', async (req, res, next) => {
    try {
      if (!mongoose.isValidObjectId(req.params.id)) {
        return res.status(404).json({ error: 'Not found' });
      }
      const doc = await Prenda.findOne({ _id: req.params.id, ...userFilter(req.userId) }).lean();
      if (!doc) return res.status(404).json({ error: 'Not found' });
      res.json(doc);
    } catch (e) {
      next(e);
    }
  });

  r.put('/:id/ocasion', async (req, res, next) => {
    try {
      if (!mongoose.isValidObjectId(req.params.id)) {
        return res.status(404).json({ error: 'Not found' });
      }
      const ocasion = req.body?.ocasion;
      if (!Array.isArray(ocasion)) {
        return res.status(400).json({ error: 'Body must include ocasion: string[]' });
      }
      const doc = await Prenda.findOneAndUpdate(
        { _id: req.params.id, ...userFilter(req.userId) },
        { $set: { ocasion: ocasion.map(String) } },
        { new: true }
      ).lean();
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
      const doc = await Prenda.findOneAndDelete({ _id: req.params.id, ...userFilter(req.userId) });
      if (!doc) return res.status(404).json({ error: 'Not found' });
      try {
        if (doc.imagen_url?.startsWith('/uploads/')) {
          const diskPath = path.join(uploadsRoot(), doc.imagen_url.replace(/^\/uploads\//, ''));
          await fs.promises.unlink(diskPath);
        }
      } catch {
        /* ignore missing file */
      }
      res.json({ ok: true });
    } catch (e) {
      next(e);
    }
  });

  return r;
}
