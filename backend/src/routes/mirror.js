import { Router } from 'express';
import { openrouterChat } from '../services/openrouter.js';
import { parseJsonFromModelText } from '../utils/parseJsonBlock.js';
import { isAllowedMirrorImageRef } from '../utils/imageUrlPolicy.js';

const MIRROR_JSON_INSTRUCTION = `You are a fashion mirror assistant. Reply with ONLY valid JSON (no markdown) in this shape:
{"score":0-10,"confidence":0-1,"summary":"short text","suggestions":["..."],"detectedItems":[{"label":"...","tipo":"superior|inferior|zapatos|abrigo|vestido","notes":"..."}]}`;

/** @param {import('../config.types.js').AppConfig} config */
export function mirrorRouter(config) {
  const r = Router();

  r.post('/analyze', async (req, res, next) => {
    try {
      const prompt =
        typeof req.body?.userPrompt === 'string'
          ? req.body.userPrompt
          : (typeof req.body?.prompt === 'string' ? req.body.prompt : '');
      if (!prompt.trim()) return res.status(400).json({ error: 'prompt required' });

      const data = await openrouterChat(config, {
        model: config.openrouterModel,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: MIRROR_JSON_INSTRUCTION },
          { role: 'user', content: prompt.slice(0, 12000) },
        ],
      });

      const content = data?.choices?.[0]?.message?.content || '';
      const parsed = parseJsonFromModelText(content) || {
        score: 0,
        confidence: 0,
        summary: content.slice(0, 400),
        suggestions: [],
        detectedItems: [],
      };
      res.json(parsed);
    } catch (e) {
      next(e);
    }
  });

  r.post('/analyze-frame', async (req, res, next) => {
    try {
      const frame =
        typeof req.body?.imageDataUrl === 'string'
          ? req.body.imageDataUrl
          : (typeof req.body?.image_data_url === 'string'
              ? req.body.image_data_url
              : (typeof req.body?.frame === 'string' ? req.body.frame : ''));
      const context = req.body?.context && typeof req.body.context === 'object' ? req.body.context : {};
      const userNotes = typeof req.body?.userNotes === 'string' ? req.body.userNotes : '';
      if (!isAllowedMirrorImageRef(frame)) {
        return res.status(400).json({ error: 'frame must be a data URL (jpeg/png/webp base64)' });
      }

      const ctxText = JSON.stringify(context).slice(0, 4000);
      const notesText = userNotes.trim().slice(0, 1000);
      const data = await openrouterChat(config, {
        model: config.openrouterModel,
        response_format: { type: 'json_object' },
        messages: [
          { role: 'system', content: MIRROR_JSON_INSTRUCTION },
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: `Context JSON: ${ctxText}\n${
                  notesText ? `User notes: ${notesText}\n` : ''
                }Evaluate the outfit in the image.`,
              },
              { type: 'image_url', image_url: { url: frame } },
            ],
          },
        ],
      });

      const content = data?.choices?.[0]?.message?.content || '';
      const parsed = parseJsonFromModelText(content) || {
        score: 0,
        confidence: 0,
        summary: 'Could not parse model output',
        suggestions: [],
        detectedItems: [],
      };
      res.json(parsed);
    } catch (e) {
      next(e);
    }
  });

  return r;
}
