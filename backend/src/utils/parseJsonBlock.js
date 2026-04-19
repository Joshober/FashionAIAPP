/**
 * @param {string} text
 * @returns {Record<string, unknown>|null}
 */
export function parseJsonFromModelText(text) {
  if (!text || typeof text !== 'string') return null;
  let t = text.trim();
  if (t.startsWith('```')) {
    t = t.replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
  }
  try {
    return JSON.parse(t);
  } catch {
    return null;
  }
}
