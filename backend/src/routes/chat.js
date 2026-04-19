import { Router } from 'express';
import { Prenda } from '../models/Prenda.js';
import { UserProfile } from '../models/UserProfile.js';
import { userFilter } from '../utils/userScope.js';
import { openrouterChat, stripAccidentalIds } from '../services/openrouter.js';
import { parseJsonFromModelText } from '../utils/parseJsonBlock.js';

function formatWardrobeForPrompt(prendas) {
  return prendas
    .map((p, idx) => {
      const occ = Array.isArray(p.ocasion) ? p.ocasion.join(',') : '';
      return `Garment#${idx + 1}: slot=${p.tipo}; class=${p.clase_nombre}; color=${p.color}; occasions=${occ}`;
    })
    .join('\n');
}

const CHAT_SYSTEM = `You are a wardrobe stylist. You MUST respond with a single JSON object only (no markdown), shape:
{"reply":"natural language for the user","outfitGeneration":null or {"style_preference":"string","formality":"string","palette":"string","notes":"string"}}
Use outfitGeneration when the user wants outfit ideas; otherwise null. Never include MongoDB ids or hex-looking ids in reply.`;

/** @param {import('../config.types.js').AppConfig} config */
export function chatRouter(config) {
  const r = Router();

  r.post('/', async (req, res, next) => {
    try {
      const history = Array.isArray(req.body?.messages) ? req.body.messages : [];
      const fromHistory = [...history].reverse().find(
        (m) => m && typeof m === 'object' && m.role === 'user' && typeof m.content === 'string'
      );
      const historyMessage = fromHistory?.content;
      const message =
        typeof req.body?.message === 'string'
          ? req.body.message
          : (typeof req.body?.text === 'string'
              ? req.body.text
              : (typeof historyMessage === 'string' ? historyMessage : null));

      if (!message || typeof message !== 'string') {
        return res.status(400).json({ error: 'message (string) required' });
      }

      const [prendas, profile] = await Promise.all([
        Prenda.find(userFilter(req.userId)).lean(),
        UserProfile.findOne(userFilter(req.userId)).lean(),
      ]);

      const prefs = profile?.preferences || {};
      const wardrobeBlock = formatWardrobeForPrompt(prendas);

      const data = await openrouterChat(config, {
        model: config.openrouterModel,
        response_format: { type: 'json_object' },
        messages: [
          {
            role: 'system',
            content: `${CHAT_SYSTEM}\nUser preferences JSON: ${JSON.stringify(prefs).slice(0, 2000)}\nWardrobe:\n${wardrobeBlock.slice(0, 12000)}`,
          },
          { role: 'user', content: message.slice(0, 8000) },
        ],
      });

      const raw = data?.choices?.[0]?.message?.content || '{}';
      const parsed = parseJsonFromModelText(raw) || {};
      const reply = stripAccidentalIds(
        typeof parsed.reply === 'string' ? parsed.reply : 'Thanks for your message.'
      );
      const outfitGeneration =
        parsed.outfitGeneration && typeof parsed.outfitGeneration === 'object'
          ? parsed.outfitGeneration
          : null;

      res.json({ reply, outfitGeneration, message: { role: 'assistant', content: reply } });
    } catch (e) {
      next(e);
    }
  });

  r.post('/transcribe', async (req, res, next) => {
    try {
      const audioB64 =
        typeof req.body?.audioBase64 === 'string'
          ? req.body.audioBase64
          : (typeof req.body?.audio === 'string' ? req.body.audio : req.body?.wav);
      if (!audioB64 || typeof audioB64 !== 'string') {
        return res.status(400).json({ error: 'audioBase64 (base64 wav) required' });
      }
      if (audioB64.length > config.maxAudioBase64Chars) {
        return res.status(413).json({ error: 'Audio payload too large' });
      }

      const data = await openrouterChat(config, {
        model: config.openrouterSttModel,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: 'Transcribe the speech clearly as plain text only.' },
              {
                type: 'input_audio',
                input_audio: { data: audioB64, format: 'wav' },
              },
            ],
          },
        ],
      });

      const text = data?.choices?.[0]?.message?.content || '';
      res.json({ text: String(text).trim() });
    } catch (e) {
      next(e);
    }
  });

  r.post('/tts', async (req, res, next) => {
    try {
      const text = typeof req.body?.text === 'string' ? req.body.text : '';
      if (!text.trim()) return res.status(400).json({ error: 'text required' });
      if (text.length > config.maxTtsChars) {
        return res.status(413).json({ error: 'text too long for TTS' });
      }

      const data = await openrouterChat(config, {
        model: config.openrouterAudioModel,
        modalities: ['text', 'audio'],
        audio: { voice: config.openrouterTtsVoice, format: config.openrouterTtsFormat },
        messages: [
          {
            role: 'user',
            content: `Speak the following naturally in one short paragraph (under 30 seconds). Do not add commentary:\n${text}`,
          },
        ],
      });

      const msg = data?.choices?.[0]?.message;
      const audio = msg?.audio;
      let audioBase64 = '';
      if (audio?.data) audioBase64 = audio.data;
      else if (typeof audio === 'string') audioBase64 = audio;

      if (!audioBase64) {
        return res.status(502).json({
          error: 'TTS model did not return audio; check OPENROUTER_AUDIO_MODEL / modalities support',
          textFallback: text.slice(0, 500),
        });
      }

      res.json({
        format: config.openrouterTtsFormat,
        audio: audioBase64,
        audioBase64,
        mimeType: config.openrouterTtsFormat === 'wav' ? 'audio/wav' : `audio/${config.openrouterTtsFormat}`,
      });
    } catch (e) {
      next(e);
    }
  });

  return r;
}
