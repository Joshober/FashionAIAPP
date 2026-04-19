import { vitClassToTipo } from './vitClassToTipo.js';

/**
 * @param {Record<string, unknown>} raw
 */
export function normalizeClassifyResponse(raw) {
  const top3 = Array.isArray(raw.top3) ? raw.top3 : [];
  let claseNombre =
    typeof raw.clase_nombre === 'string'
      ? raw.clase_nombre
      : typeof raw.label === 'string'
        ? raw.label
        : '';
  let confianza =
    typeof raw.confianza === 'number'
      ? raw.confianza
      : typeof raw.confidence === 'number'
        ? raw.confidence
        : 0;

  if ((!claseNombre || claseNombre === 'unknown') && top3[0]) {
    const t0 = top3[0];
    if (typeof t0 === 'object' && t0) {
      claseNombre = String(t0.label || t0.class || t0.name || claseNombre);
      if (typeof t0.score === 'number') confianza = t0.score;
      else if (typeof t0.confidence === 'number') confianza = t0.confidence;
    }
  }

  const color =
    typeof raw.color === 'string' && raw.color && raw.color !== 'unknown' ? raw.color : '';

  const tipo = typeof raw.tipo === 'string' && raw.tipo ? raw.tipo : vitClassToTipo(claseNombre);

  return {
    tipo,
    color,
    clase_nombre: claseNombre || 'unknown',
    confianza: Number.isFinite(confianza) ? confianza : 0,
    top3,
  };
}
