import { Router } from 'express';
import { openrouterChat } from '../services/openrouter.js';
import { parseJsonFromModelText } from '../utils/parseJsonBlock.js';
import { isAllowedMirrorImageRef } from '../utils/imageUrlPolicy.js';
import { MIRROR_STYLIST_SYSTEM_PROMPT } from '../utils/mirrorSystemPrompt.js';

function buildAnalyzeFrameUserText(context, userNotes) {
  const lines = [
    'Analyze the outfit in the attached image. The user is preparing for the occasion described below.',
    'Give preparation-focused feedback: what works for that occasion and 1–2 concrete tips to strengthen the look. Do not criticise or judge the outfit; keep tone supportive and constructive.',
    '',
    'Context:',
    `Event / occasion: ${context?.event ?? '—'}`,
    `Weather / location: ${context?.weather ?? '—'}`,
    `Time of day: ${context?.time ?? '—'}`,
    `Style preference: ${context?.user_profile?.style_preference ?? '—'}`,
    context?.location ? `Location: ${context.location}` : '',
    '',
    userNotes.trim() ? `User notes: ${userNotes.trim()}` : '',
    userNotes.trim() ? '' : '',
    'Return: (1) style, silhouette, color, fit, occasion alignment, seasonal match; (2) overall score and confidence (0–100); (3) expert_feedback focused on preparing for the stated occasion; (4) 2–4 upgrade_suggestions as tips; (5) new_detected_items if you see distinct garments. Reply with only the JSON object, no markdown or extra text.',
  ].filter(Boolean);
  return lines.join('\n');
}

/** @param {import('../config.types.js').AppConfig} config */
export function mirrorRouter(config) {
  const r = Router();

  r.get('/status', (_req, res) => {
    res.json({
      openrouter: {
        configured: Boolean(config.openrouterApiKey),
        model: config.openrouterModel || null,
        baseUrl: config.openrouterBaseUrl || null,
      },
    });
  });

  r.post('/analyze', async (req, res, next) => {
    try {
      if (!config.openrouterApiKey) {
        return res.status(503).json({
          error: 'OpenRouter not configured',
          hint: 'Set OPENROUTER_API_KEY in backend environment',
        });
      }

      const prompt =
        typeof req.body?.userPrompt === 'string'
          ? req.body.userPrompt
          : typeof req.body?.prompt === 'string'
            ? req.body.prompt
            : '';
      if (!prompt.trim()) return res.status(400).json({ error: 'userPrompt required' });

      const data = await openrouterChat(config, {
        model: config.openrouterModel,
        response_format: { type: 'json_object' },
        temperature: 0.3,
        messages: [
          { role: 'system', content: MIRROR_STYLIST_SYSTEM_PROMPT },
          { role: 'user', content: prompt.trim().slice(0, 12000) },
        ],
      });

      const content = data?.choices?.[0]?.message?.content || '';
      const parsed = parseJsonFromModelText(content);
      if (parsed && typeof parsed === 'object') {
        return res.json(parsed);
      }
      return res.status(502).json({
        error: 'Invalid JSON from model',
        raw: content ? content.slice(0, 500) : null,
      });
    } catch (e) {
      next(e);
    }
  });

  r.post('/analyze-frame', async (req, res, next) => {
    try {
      if (!config.openrouterApiKey) {
        return res.status(503).json({
          error: 'OpenRouter not configured',
          hint: 'Set OPENROUTER_API_KEY in backend environment',
        });
      }

      const frame =
        typeof req.body?.imageDataUrl === 'string'
          ? req.body.imageDataUrl
          : typeof req.body?.image_data_url === 'string'
            ? req.body.image_data_url
            : typeof req.body?.frame === 'string'
              ? req.body.frame
              : '';
      const context = req.body?.context && typeof req.body.context === 'object' ? req.body.context : {};
      const userNotes = typeof req.body?.userNotes === 'string' ? req.body.userNotes : '';

      if (!isAllowedMirrorImageRef(frame)) {
        return res.status(400).json({ error: 'frame must be a data URL (jpeg/png/webp base64)' });
      }

      if (frame.length > 8_000_000) {
        return res.status(413).json({ error: 'imageDataUrl too large (max ~8MB string)' });
      }

      const userText = buildAnalyzeFrameUserText(context, userNotes);

      const data = await openrouterChat(config, {
        model: config.openrouterModel,
        response_format: { type: 'json_object' },
        temperature: 0.3,
        max_tokens: 1200,
        messages: [
          { role: 'system', content: MIRROR_STYLIST_SYSTEM_PROMPT },
          {
            role: 'user',
            content: [
              { type: 'text', text: userText },
              { type: 'image_url', image_url: { url: frame } },
            ],
          },
        ],
      });

      const content = data?.choices?.[0]?.message?.content || '';
      const parsed = parseJsonFromModelText(content);
      if (parsed && typeof parsed === 'object') {
        return res.json(parsed);
      }
      return res.status(502).json({
        error: 'Invalid JSON from model',
        raw: content ? content.slice(0, 1000) : null,
      });
    } catch (e) {
      next(e);
    }
  });

  return r;
}
